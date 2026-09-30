document.addEventListener("DOMContentLoaded", function () {

    const filterButtons = document.querySelectorAll(".month-filter");
    const dayCards = document.querySelectorAll(".day-card");
    const timelineDates = document.querySelectorAll(".timeline-date");

    let currentFilter = "all";

    function getVisibleCount(element) {
        const lp = Number(element.dataset.lp || 0);
        const ps = Number(element.dataset.ps || 0);
        if (currentFilter === "LP") {
            return lp;
        }
        if (currentFilter === "PS") {
            return ps;
        }
        return lp + ps;
    }

    function updateCards() {
        dayCards.forEach(function (card) {
            const count = getVisibleCount(card);
            if (count === 0) {
                card.style.display = "none";
            } else {
                card.style.display = "";
            }
            const totalElement =
                card.querySelector(".total-count");
            const lpElement =
                card.querySelector(".lp-count");
            const psElement =
                card.querySelector(".ps-count");

            if (totalElement) {
                totalElement.textContent = count;
            }

            if (lpElement) {
                const lp = Number(card.dataset.lp || 0);
                if (currentFilter === "PS") {
                    lpElement.style.display = "none";
                } else {
                    lpElement.style.display = "";
                    lpElement.textContent =
                        lp + " Stellen";
                }
            }

            if (psElement) {
                const ps = Number(card.dataset.ps || 0);
                if (currentFilter === "LP") {
                    psElement.style.display = "none";
                } else {
                    psElement.style.display = "";
                    psElement.textContent =
                        ps + " Personal";
                }
            }
        });
    }

    function updateTimeline() {
        timelineDates.forEach(function (dateElement) {
            const lp = Number(dateElement.dataset.lp || 0);
            const ps = Number(dateElement.dataset.ps || 0);
            let count = lp + ps;
            if (currentFilter === "LP") {
                count = lp;
            }
            if (currentFilter === "PS") {
                count = ps;
            }
            const timelineItem =
                dateElement.closest(".timeline-item");
            if (timelineItem) {
                if (count === 0) {
                    timelineItem.style.display = "none";
                } else {
                    timelineItem.style.display = "";
                }
            }
        });
    }

    filterButtons.forEach(function (button) {
        button.addEventListener("click", function () {
            currentFilter = button.dataset.filter;
            filterButtons.forEach(function (otherButton) {
                otherButton.classList.remove("active");
            });
            button.classList.add("active");
            updateCards();
            updateTimeline();
            updateChart();
        });
    });

    const chartContainer =
        document.getElementById("month-chart");
    if (chartContainer && typeof d3 !== "undefined") {
        const data = Array.from(
            chartContainer.querySelectorAll(".chart-data")
        ).map(function (element) {
            return {
                date: element.dataset.date,
                day: Number(element.dataset.day),
                lp: Number(element.dataset.lp),
                ps: Number(element.dataset.ps)
            };
        });

        const margin = {
            top: 20,
            right: 20,
            bottom: 50,
            left: 45
        };
        function getChartWidth() {
            const width =
                chartContainer.clientWidth;

            return Math.max(width, 300);
        }
        function drawChart() {

            d3.select(chartContainer)
                .select("svg")
                .remove();
            const width = getChartWidth();
            const height = 300;
            const innerWidth =
                width - margin.left - margin.right;
            const innerHeight =
                height - margin.top - margin.bottom;
            const svg = d3
                .select(chartContainer)
                .append("svg")
                .attr("width", width)
                .attr("height", height);
            const chart = svg
                .append("g")
                .attr(
                    "transform",
                    "translate(" +
                    margin.left +
                    "," +
                    margin.top +
                    ")"
                );
            const filteredData = data.map(function (item) {
                if (currentFilter === "LP") {
                    return {
                        date: item.date,
                        day: item.day,
                        lp: item.lp,
                        ps: 0
                    };
                }
                if (currentFilter === "PS") {
                    return {
                        date: item.date,
                        day: item.day,
                        lp: 0,
                        ps: item.ps
                    };
                }
                return item;
            });

            const maxValue = d3.max(
                filteredData,
                function (d) {
                    return d.lp + d.ps;
                }
            );

            const x = d3
                .scaleBand()
                .domain(
                    filteredData.map(function (d) {
                        return d.day;
                    })
                )
                .range([0, innerWidth])
                .padding(0.15);
            const y = d3
                .scaleLinear()
                .domain([
                    0,
                    Math.max(1, maxValue)
                ])
                .nice()
                .range([innerHeight, 0]);

            const stack = d3
                .stack()
                .keys(["lp", "ps"]);
            const stackedData =
                stack(filteredData);

            chart
                .selectAll(".bar-group")
                .data(stackedData)
                .enter()
                .append("g")
                .attr("class", function (d) {
                    return "bar-group bar-" + d.key;
                })
                .selectAll("rect")
                .data(function (d) {
                    return d.map(function (item, index) {
                        return {
                            day: filteredData[index].day,
                            date: filteredData[index].date,
                            key: d.key,
                            value: item,
                            count: filteredData[index][d.key]
                        };
                    });
                })
                .enter()
                .append("rect")
                .attr("class", "month-bar")
                .attr("x", function (d) {
                    return x(d.day);
                })
                .attr("y", function (d) {
                    return y(d.value[1]);
                })
                .attr("width", x.bandwidth())
                .attr("height", function (d) {
                    return y(d.value[0]) - y(d.value[1]);
                })
                .on("click", function (event, d) {
                    if (d.count === 0) {
                        return;
                    }
                    window.location.href =
                        "overview-" +
                        d.date.substring(5, 7) +
                        "-" +
                        d.date.substring(8, 10) +
                        ".html";
                })
                .append("title")
                .text(function (d) {
                    return (
                        d.date +
                        ": " +
                        d.count +
                        " " +
                        (d.key === "lp"
                            ? "Stellen"
                            : "Personal")
                    );
                });
            chart
                .append("g")
                .attr(
                    "transform",
                    "translate(0," +
                    innerHeight +
                    ")"
                )
                .call(
                    d3.axisBottom(x)
                );
            chart
                .append("g")
                .call(
                    d3.axisLeft(y)
                );
            chart
                .append("text")
                .attr("class", "chart-axis-label")
                .attr("x", innerWidth / 2)
                .attr("y", innerHeight + 42)
                .attr("text-anchor", "middle")
                .text("Tag");
            chart
                .append("text")
                .attr("class", "chart-axis-label")
                .attr("transform", "rotate(-90)")
                .attr("x", -innerHeight / 2)
                .attr("y", -35)
                .attr("text-anchor", "middle")
                .text("Anzahl");
        }
        function updateChart() {
            drawChart();
        }
        drawChart();
        window.addEventListener(
            "resize",
            function () {
                drawChart();
            }
        );
    }
    updateCards();
    updateTimeline();
});