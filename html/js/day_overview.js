document.addEventListener("DOMContentLoaded", function () {

    const buttons = document.querySelectorAll(".day-filter");
    const cards = document.querySelectorAll(".day-ad-card");


    buttons.forEach(function (button) {

        button.addEventListener("click", function () {

            const filter = button.dataset.filter;


            /*
             * Update active button
             */

            buttons.forEach(function (otherButton) {

                otherButton.classList.remove("active");

            });

            button.classList.add("active");


            /*
             * Filter advertisement cards
             */

            cards.forEach(function (card) {

                const type = card.dataset.type;


                if (filter === "all") {

                    card.style.display = "";

                }

                else if (type === filter) {

                    card.style.display = "";

                }

                else {

                    card.style.display = "none";

                }

            });

        });

    });

});
