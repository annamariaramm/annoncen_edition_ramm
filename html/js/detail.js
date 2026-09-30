document.addEventListener("DOMContentLoaded", function () {
    // Tastaturnavigation mit den Pfeiltasten (links/rechts)
    document.addEventListener("keydown", function (event) {
        if (event.key === "ArrowLeft") {
            const prevLink = document.querySelector(".btn-outline-secondary[href*='_']");
            if (prevLink && prevLink.innerText.includes("vorherige")) {
                prevLink.click();
            }
        } else if (event.key === "ArrowRight") {
            const nextLinks = document.querySelectorAll(".btn-outline-secondary[href*='_']");
            nextLinks.forEach(link => {
                if (link.innerText.includes("nächste")) {
                    link.click();
                }
            });
        }
    });
});