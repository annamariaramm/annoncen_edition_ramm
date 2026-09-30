document.addEventListener("DOMContentLoaded", function () {

    const tableBody =
        document.getElementById("personen-tabelle-body");

    const rows =
        Array.from(
            tableBody.querySelectorAll(".person-zeile")
        );

    const personCount =
        document.getElementById("personen-anzahl");

    const selectionCount =
        document.getElementById("auswahl-anzahl");

    const downloadButton =
        document.getElementById("download-personen-btn");

    const resetButton =
        document.getElementById("reset-selection-btn");

    const noResults =
        document.getElementById("keine-ergebnisse");


    /* --------------------------------------------------
       Aktuell ausgewählter Geschlechterfilter
       -------------------------------------------------- */

    let currentFilter = "all";


    function getSelectedFilter() {

        const selected =
            document.querySelector(
                'input[name="sex-filter"]:checked'
            );

        return selected
            ? selected.value
            : "all";
    }


    /* --------------------------------------------------
       Tabelle entsprechend des Filters aktualisieren
       -------------------------------------------------- */

    function updateTable() {

        currentFilter =
            getSelectedFilter();

        let visibleRows = 0;


        rows.forEach(function (row) {

            const countCell =
                row.querySelector(".personen-count");

            const linksAll =
                row.querySelector(".links-all");

            const linksFemale =
                row.querySelector(".links-female");

            const linksMale =
                row.querySelector(".links-male");


            const allCount =
                Number(row.dataset.allCount);

            const femaleCount =
                Number(row.dataset.femaleCount);

            const maleCount =
                Number(row.dataset.maleCount);


            let count = allCount;


            /* ------------------------------------------
               Alle
               ------------------------------------------ */

            if (currentFilter === "all") {

                count = allCount;

                linksAll.style.display =
                    "inline-block";

                linksFemale.style.display =
                    "none";

                linksMale.style.display =
                    "none";
            }


            /* ------------------------------------------
               Frauen
               ------------------------------------------ */

            else if (currentFilter === "female") {

                count = femaleCount;

                linksAll.style.display =
                    "none";

                linksFemale.style.display =
                    "inline-block";

                linksMale.style.display =
                    "none";
            }


            /* ------------------------------------------
               Männer
               ------------------------------------------ */

            else if (currentFilter === "male") {

                count = maleCount;

                linksAll.style.display =
                    "none";

                linksFemale.style.display =
                    "none";

                linksMale.style.display =
                    "inline-block";
            }


            /* ------------------------------------------
               Anzahl aktualisieren
               ------------------------------------------ */

            countCell.textContent =
                count;


            /* ------------------------------------------
               Zeile anzeigen / ausblenden
               ------------------------------------------ */

            if (count > 0) {

                row.style.display = "";

                visibleRows++;
            }

            else {

                row.style.display = "none";

                const checkbox =
                    row.querySelector(
                        ".person-auswahl"
                    );

                checkbox.checked = false;

                row.classList.remove(
                    "selected"
                );
            }
        });


        /* Anzahl sichtbarer Personen */

        personCount.textContent =
            visibleRows;


        /* Hinweis bei keinen Ergebnissen */

        noResults.style.display =
            visibleRows === 0
                ? "block"
                : "none";


        updateSelectionCounter();
    }


    /* --------------------------------------------------
       Zeilenauswahl
       -------------------------------------------------- */

    rows.forEach(function (row) {

        const checkbox =
            row.querySelector(
                ".person-auswahl"
            );


        /* Direkte Checkbox */

        checkbox.addEventListener(
            "change",
            function () {

                row.classList.toggle(
                    "selected",
                    checkbox.checked
                );

                updateSelectionCounter();
            }
        );


        /* Klick auf die übrige Zeile */

        row.addEventListener(
            "click",
            function (event) {

                /*
                 * Diese Elemente sollen nicht dazu führen,
                 * dass die ganze Zeile ausgewählt wird:
                 *
                 * - Links zu Annoncen
                 * - Checkbox
                 * - summary des Dropdowns
                 * - alles innerhalb eines <details>
                 */

                if (
                    event.target.tagName === "A" ||
                    event.target.tagName === "INPUT" ||
                    event.target.tagName === "SUMMARY" ||
                    event.target.closest("details")
                ) {
                    return;
                }


                checkbox.checked =
                    !checkbox.checked;


                row.classList.toggle(
                    "selected",
                    checkbox.checked
                );


                updateSelectionCounter();
            }
        );
    });


    /* --------------------------------------------------
       Anzahl ausgewählter Personenbezeichnungen
       -------------------------------------------------- */

    function updateSelectionCounter() {

        const selectedRows =
            rows.filter(function (row) {

                const checkbox =
                    row.querySelector(
                        ".person-auswahl"
                    );

                return checkbox.checked;
            });


        selectionCount.textContent =
            selectedRows.length +
            " ausgewählt";
    }


    /* --------------------------------------------------
       IDs der ausgewählten Personenbezeichnungen
       -------------------------------------------------- */

    function getSelectedIDs() {

        /*
         * Set verhindert doppelte IDs.
         *
         * Beispiel:
         * Zwei ausgewählte Personenbezeichnungen
         * können auf dieselbe Annonce verweisen.
         * Diese Annonce erscheint im Download trotzdem
         * nur einmal.
         */

        const ids =
            new Set();


        rows.forEach(function (row) {

            const checkbox =
                row.querySelector(
                    ".person-auswahl"
                );


            if (!checkbox.checked) {
                return;
            }


            const data =
                row.querySelector(
                    ".ids-data"
                );


            let idString = "";


            /* ------------------------------------------
               Welche ID-Liste soll verwendet werden?
               ------------------------------------------ */

            if (currentFilter === "all") {

                idString =
                    data.dataset.allIds || "";
            }

            else if (currentFilter === "female") {

                idString =
                    data.dataset.femaleIds || "";
            }

            else if (currentFilter === "male") {

                idString =
                    data.dataset.maleIds || "";
            }


            if (!idString) {
                return;
            }


            /* IDs auslesen */

            idString
                .split("|")
                .filter(Boolean)
                .forEach(function (id) {

                    ids.add(id);
                });
        });


        /*
         * Alphabetische / lexikographische Sortierung
         * der IDs.
         */

        return Array
            .from(ids)
            .sort();
    }


    /* --------------------------------------------------
       TXT-Download
       -------------------------------------------------- */

    downloadButton.addEventListener(
        "click",
        function () {

            const ids =
                getSelectedIDs();


            if (ids.length === 0) {

                alert(
                    "Bitte wählen Sie mindestens eine Personenbezeichnung aus."
                );

                return;
            }


            /*
             * Eine ID pro Zeile
             */

            const idsText =
                ids.join("\n");


            const blob =
                new Blob(
                    [idsText],
                    {
                        type:
                            "text/plain;charset=utf-8"
                    }
                );


            const url =
                URL.createObjectURL(
                    blob
                );


            const link =
                document.createElement(
                    "a"
                );


            link.href =
                url;


            link.download =
                "sydsvenska_personen_annoncen_ids_" +
                new Date()
                    .toISOString()
                    .slice(0, 10) +
                ".txt";


            document.body.appendChild(
                link
            );


            link.click();


            document.body.removeChild(
                link
            );


            URL.revokeObjectURL(
                url
            );
        }
    );


    /* --------------------------------------------------
       Auswahl zurücksetzen
       -------------------------------------------------- */

    resetButton.addEventListener(
        "click",
        function () {

            rows.forEach(function (row) {

                const checkbox =
                    row.querySelector(
                        ".person-auswahl"
                    );


                checkbox.checked =
                    false;


                row.classList.remove(
                    "selected"
                );
            });


            updateSelectionCounter();
        }
    );


    /* --------------------------------------------------
       Geschlechterfilter
       -------------------------------------------------- */

    document
        .querySelectorAll(
            'input[name="sex-filter"]'
        )
        .forEach(function (radio) {

            radio.addEventListener(
                "change",
                updateTable
            );
        });


    /* --------------------------------------------------
       Initialisierung
       -------------------------------------------------- */

    updateTable();

});