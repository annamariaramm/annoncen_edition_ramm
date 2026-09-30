document.addEventListener("DOMContentLoaded", function () {
    let indexData = [];
    let filteredData = [];

    // DOM-Elemente
    const searchText = document.getElementById("search-text");
    const searchId = document.getElementById("search-id");
    const filterType = document.getElementById("filter-type");
    const filterSex = document.getElementById("filter-sex");
    const filterOccupation = document.getElementById("filter-occupation");
    const filterPlace = document.getElementById("filter-place");
    const filterTrait = document.getElementById("filter-trait");
    const filterSkill = document.getElementById("filter-skill");
    const filterDate = document.getElementById("filter-date");

    const btnReset = document.getElementById("btn-reset");
    const btnDownloadIds = document.getElementById("btn-download-ids");
    const resultsCount = document.getElementById("results-count");
    const resultsGrid = document.getElementById("results-grid");

    // Index laden
    fetch("js/search_index.json")
        .then(response => response.json())
        .then(data => {
            indexData = data;
            applyFilters();
        })
        .catch(err => console.error("Fehler beim Laden des Suchindex:", err));

    // Hilfsfunktion: Ausgewählte Werte aus Multiple-Select ermitteln
    function getSelectedOptions(selectElement) {
        if (!selectElement) return [];
        return Array.from(selectElement.selectedOptions).map(opt => opt.value);
    }

    // Hauptfunktion zum Filtern
    function applyFilters() {
        const textVal = searchText ? searchText.value.trim().toLowerCase() : "";
        const idVal = searchId ? searchId.value.trim().toLowerCase() : "";
        const typeVal = filterType ? filterType.value : "";
        const sexVal = filterSex ? filterSex.value : "";

        const selOccupations = getSelectedOptions(filterOccupation);
        const selPlaces = getSelectedOptions(filterPlace);
        const selTraits = getSelectedOptions(filterTrait);
        const selSkills = getSelectedOptions(filterSkill);
        const selDates = getSelectedOptions(filterDate);

        filteredData = indexData.filter(item => {
            // ID-Filter
            if (idVal && !item.id.toLowerCase().includes(idVal)) return false;

            // Freitextsuche
            if (textVal && !item.text.toLowerCase().includes(textVal) && !item.id.toLowerCase().includes(textVal)) return false;

            // Typ-Filter (LP/PS)
            if (typeVal && item.type !== typeVal) return false;

            // Geschlecht
            if (sexVal && !item.sex.includes(sexVal)) return false;

            // Berufe
            if (selOccupations.length > 0) {
                const itemOccs = (item.occupations || []).map(o => o.toLowerCase());
                if (!selOccupations.some(occ => itemOccs.includes(occ.toLowerCase()))) return false;
            }

            // Orte
            if (selPlaces.length > 0) {
                const itemPlaces = (item.places || []).map(p => p.toLowerCase());
                if (!selPlaces.some(plc => itemPlaces.includes(plc.toLowerCase()))) return false;
            }

            // Eigenschaften
            if (selTraits.length > 0) {
                const itemTraits = (item.traits || []).map(t => t.toLowerCase());
                if (!selTraits.some(trt => itemTraits.includes(trt.toLowerCase()))) return false;
            }

            // Kenntnisse
            if (selSkills.length > 0) {
                const itemSkills = (item.skills || []).map(s => s.toLowerCase());
                if (!selSkills.some(skl => itemSkills.includes(skl.toLowerCase()))) return false;
            }

            // Anstellungsdatum
            if (selDates.length > 0) {
                const itemDates = (item.beginDates || []).map(d => d.toLowerCase());
                if (!selDates.some(dt => itemDates.includes(dt.toLowerCase()))) return false;
            }

            return true;
        });

        renderResults();
    }

    // Ergebnisse in HTML rendern
    function renderResults() {
        if (resultsCount) resultsCount.innerText = `${filteredData.length} Annoncen gefunden`;
        if (btnDownloadIds) btnDownloadIds.disabled = filteredData.length === 0;

        if (!resultsGrid) return;
        resultsGrid.innerHTML = "";

        if (filteredData.length === 0) {
            resultsGrid.innerHTML = `
                <div class="col-12 text-center my-5 text-muted">
                    <i class="bi bi-search fs-1"></i>
                    <p class="mt-2">Keine Annoncen gefunden, die den gewählten Kriterien entsprechen.</p>
                </div>`;
            return;
        }

        filteredData.forEach(item => {
            const col = document.createElement("div");
            col.className = "col";
            col.innerHTML = `
                <div class="card h-100 shadow-sm">
                    <img src="images/${item.id}.jpg" class="card-img-top p-2" alt="${item.id}" loading="lazy" style="height: 180px; object-fit: contain; background: #f8f9fa;">
                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title h6">${item.id}</h5>
                        <p class="card-text small text-muted mb-2">Datum: ${item.pubDate}</p>
                        <p class="card-text small text-truncate mb-3">${item.text}</p>
                        <a href="${item.id}.html" class="btn btn-sm btn-outline-primary mt-auto w-100">Detailansicht</a>
                    </div>
                </div>
            `;
            resultsGrid.appendChild(col);
        });
    }

    // Reset-Button
    if (btnReset) {
        btnReset.addEventListener("click", function () {
            if (searchText) searchText.value = "";
            if (searchId) searchId.value = "";
            if (filterType) filterType.value = "";
            if (filterSex) filterSex.value = "";

            [filterOccupation, filterPlace, filterTrait, filterSkill, filterDate].forEach(select => {
                if (select) {
                    Array.from(select.options).forEach(opt => opt.selected = false);
                }
            });

            applyFilters();
        });
    }

    // ID-Liste als TXT herunterladen
    if (btnDownloadIds) {
        btnDownloadIds.addEventListener("click", function () {
            if (filteredData.length === 0) return;

            const idsText = filteredData.map(item => item.id).join("\n");
            const blob = new Blob([idsText], { type: "text/plain;charset=utf-8" });
            const url = URL.createObjectURL(blob);
            const a = document.createElement("a");
            a.href = url;
            a.download = `sydsvenska_annoncen_ids_${new Date().toISOString().slice(0, 10)}.txt`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        });
    }

    // TOGGLE-FUNKTION FÜR MEHRFACHAUSWAHL (Eintragsauswahl per einfachem Klick an/abwählen)
    const multiSelects = [filterOccupation, filterPlace, filterTrait, filterSkill, filterDate];
    multiSelects.forEach(selectEl => {
        if (!selectEl) return;

        selectEl.addEventListener("mousedown", function (e) {
            if (e.target.tagName === "OPTION") {
                e.preventDefault();
                e.target.selected = !e.target.selected;
                selectEl.dispatchEvent(new Event("change"));
                selectEl.focus();
            }
        });
    });

    // Event Listener für alle Filter
    [searchText, searchId].forEach(el => el && el.addEventListener("input", applyFilters));
    [filterType, filterSex, filterOccupation, filterPlace, filterTrait, filterSkill, filterDate].forEach(el => el && el.addEventListener("change", applyFilters));
});