document.addEventListener("DOMContentLoaded", function () {

    const container =
        document.getElementById("today-120-content");

    if (!container || typeof EDITION_ADS === "undefined") {
        return;
    }
    const today =
        new Date();

    const historicalDate =
        new Date(
            today.getFullYear() - 120,
            today.getMonth(),
            today.getDate()
        );

    function formatISODate(date) {

        const year =
            date.getFullYear();

        const month =
            String(date.getMonth() + 1)
                .padStart(2, "0");

        const day =
            String(date.getDate())
                .padStart(2, "0");

        return (
            year +
            "-" +
            month +
            "-" +
            day
        );
    }


    function formatDisplayDate(dateString) {

        const parts =
            dateString.split("-");

        return (
            parts[2] +
            "." +
            parts[1] +
            "." +
            parts[0]
        );
    }


    const targetDate =
        formatISODate(historicalDate);

    const matchingAds =
        EDITION_ADS.filter(function (ad) {

            return ad.date === targetDate;

        });


    if (matchingAds.length > 0) {

        const count =
            matchingAds.length;

        const plural =
            count === 1
                ? "Annonce"
                : "Annoncen";


        container.innerHTML =

            "<p>" +

                "Am " +
                formatDisplayDate(targetDate) +
                " sind " +
                count +
                " " +
                plural +
                " erschienen." +

            "</p>" +

            "<a " +
                'href="day-' +
                targetDate +
                '.html" ' +
                'class="btn btn-primary">' +

                "Tagesansicht ansehen" +

            "</a>";

        return;
    }

    const randomIndex =
        Math.floor(
            Math.random() *
            EDITION_ADS.length
        );

    const randomAd =
        EDITION_ADS[randomIndex];



    const randomDateAds =
        EDITION_ADS.filter(function (ad) {

            return ad.date === randomAd.date;

        });


    const randomCount =
        randomDateAds.length;

    const randomPlural =
        randomCount === 1
            ? "Annonce"
            : "Annoncen";


    container.innerHTML =

        "<p>" +

            "Heute vor 120 Jahren ist keine " +
            "Annonce erschienen." +

        "</p>" +

        "<p>" +

            "Wie wäre es alternativ mit den " +
            randomCount +
            " " +
            randomPlural +
            " vom " +
            formatDisplayDate(randomAd.date) +
            "?" +

        "</p>" +

        "<a " +
            'href="day-' +
            randomAd.date +
            '.html" ' +
            'class="btn btn-primary">' +

            "Tagesansicht ansehen" +

        "</a>";

});