document.addEventListener('DOMContentLoaded', function () {
    let places = [];
    let searchIndex = [];
    let selectedPlaceId = null;

    // 1. Ortsdaten laden
    const placesDataElement = document.getElementById('places-data');
    if (placesDataElement) {
        try {
            places = JSON.parse(placesDataElement.textContent);
        } catch (e) {
            console.error("Fehler beim Parsen der Ortsdaten:", e);
        }
    }

    // 2. Suchindex für die Annoncen-Vorschau laden
    fetch("js/search_index.json")
        .then(response => response.json())
        .then(data => {
            searchIndex = data;
        })
        .catch(err => console.error("Fehler beim Laden des Suchindex für Annoncen:", err));

    // 3. Leaflet Karte initialisieren
    const map = L.map('map').setView([55.847, 13.633], 8);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 18,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    let markersLayer = L.layerGroup().addTo(map);

    function updateMap() {
        markersLayer.clearLayers();

        const activeFilters = {
            employment: document.getElementById('filter-employment').checked,
            residence: document.getElementById('filter-residence').checked,
            application: document.getElementById('filter-application').checked
        };

        places.forEach(place => {
            let filteredTotal = 0;
            if (activeFilters.employment) filteredTotal += place.employment;
            if (activeFilters.residence) filteredTotal += place.residence;
            if (activeFilters.application) filteredTotal += place.application;

            if (filteredTotal === 0) return;

            const radius = Math.max(5, Math.min(25, Math.sqrt(filteredTotal) * 4));

            // Grundfarbe der Punkte auf schlichtes Grau (#6c757d) gesetzt
            const marker = L.circleMarker([place.lat, place.lon], {
                radius: radius,
                fillColor: '#6c757d',
                color: '#ffffff',
                weight: 1,
                opacity: 1,
                fillOpacity: 0.8
            });

            // Popups mit den gewünschten Farben (Weinrot, Beige, Buttergelb)
            let popupContent = `<strong>${place.name}</strong><br><hr style="margin: 5px 0;">`;
            if (place.employment > 0 && activeFilters.employment) {
                popupContent += `<span class="badge-employment">Anstellung: ${place.employment}</span>`;
            }
            if (place.residence > 0 && activeFilters.residence) {
                popupContent += `<span class="badge-residence">Herkunft: ${place.residence}</span>`;
            }
            if (place.application > 0 && activeFilters.application) {
                popupContent += `<span class="badge-application">Bewerbung: ${place.application}</span>`;
            }

            marker.bindPopup(popupContent);

            marker.on('click', function() {
                selectedPlaceId = place.id;
                updateAnnouncementsView(selectedPlaceId, activeFilters);
            });

            markersLayer.addLayer(marker);
        });
    }

    function updateAnnouncementsView(placeId, activeFilters) {
        const resultsGrid = document.getElementById('results-grid');
        const countContainer = document.getElementById('result-count');
        const btnDownloadIds = document.getElementById('export-txt-btn');
        
        resultsGrid.innerHTML = '';

        // Filtern der Annoncen aus dem Index, die diesen Ort und den jeweiligen Typen-Filter matchen
        const matchingAds = searchIndex.filter(ad => {
            return ad.places.some(p => {
                if (p.ref !== placeId) return false;
                if (p.type === 'employment' && activeFilters.employment) return true;
                if (p.type === 'residence' && activeFilters.residence) return true;
                if (p.type === 'application' && activeFilters.application) return true;
                return false;
            });
        });

        countContainer.textContent = matchingAds.length;
        btnDownloadIds.disabled = matchingAds.length === 0;

        if (matchingAds.length === 0) {
            resultsGrid.innerHTML = `
                <div class="col-12 text-center my-3 text-muted">
                    <p>Keine Annoncen für diesen Ort und die gewählten Filter gefunden.</p>
                </div>`;
            setupTxtExport([]);
            return;
        }

        matchingAds.forEach(item => {
            const col = document.createElement("div");
            col.className = "col";
            col.innerHTML = `
                <div class="card h-100 shadow-sm">
                    <img src="images/${item.id}.jpg" class="card-img-top p-2" alt="${item.id}" loading="lazy" style="height: 180px; object-fit: contain; background: #f8f9fa;" onerror="this.src='images/placeholder.jpg';">
                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title h6">${item.id}</h5>
                        <p class="card-text small text-muted mb-2">Datum: ${item.pubDate}</p>
                        <p class="card-text small text-truncate mb-3">${item.text}</p>
                        <a href="${item.id}.html" class="btn btn-sm btn-outline-primary mt-auto w-100" target="_blank">Detailansicht</a>
                    </div>
                </div>
            `;
            resultsGrid.appendChild(col);
        });

        setupTxtExport(matchingAds.map(ad => ad.id));
    }

    function setupTxtExport(ids) {
        const btn = document.getElementById('export-txt-btn');
        const newBtn = btn.cloneNode(true);
        btn.parentNode.replaceChild(newBtn, btn);

        newBtn.addEventListener('click', function() {
            if (!ids || ids.length === 0) return;
            const blob = new Blob([ids.join('\n')], { type: 'text/plain;charset=utf-8' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `sydsvenska_annoncen_ids_${selectedPlaceId || 'gefiltert'}.txt`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        });
    }

    // Event-Listener für Checkboxen
    document.querySelectorAll('.place-filter').forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            updateMap();
            if (selectedPlaceId) {
                const activeFilters = {
                    employment: document.getElementById('filter-employment').checked,
                    residence: document.getElementById('filter-residence').checked,
                    application: document.getElementById('filter-application').checked
                };
                updateAnnouncementsView(selectedPlaceId, activeFilters);
            }
        });
    });

    // „Alle auswählen“-Button Logik
    const btnSelectAll = document.getElementById('btn-select-all');
    if (btnSelectAll) {
        btnSelectAll.addEventListener('click', function() {
            const checkboxes = document.querySelectorAll('.place-filter');
            const allChecked = Array.from(checkboxes.every(cb => cb.checked));
            // Wenn alle an sind, alle ausmachen, sonst alle anmachen
            const targetState = !allChecked;
            checkboxes.forEach(cb => {
                cb.checked = targetState;
            });
            btnSelectAll.textContent = targetState ? "Alle abwählen" : "Alle auswählen";
            updateMap();
            if (selectedPlaceId) {
                const activeFilters = {
                    employment: document.getElementById('filter-employment').checked,
                    residence: document.getElementById('filter-residence').checked,
                    application: document.getElementById('filter-application').checked
                };
                updateAnnouncementsView(selectedPlaceId, activeFilters);
            }
        });
    }

    updateMap();
});