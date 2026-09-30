document.addEventListener("DOMContentLoaded", function () {
    const tooltip = 
        d3.select("body") 
            .append("div") 
            .attr("class", "chart-tooltip");
    function createAnnoncenChart() { 
        const container = 
            document.getElementById( 
                "chart-annoncen" 
            ); 
        if (!container) { 
            return; 
        } 
    const data = [ 
        { 
            label: "Stellenanzeigen", 
            value: STATISTIKEN.annoncen .stellenanzeigen 
        }, 
        { 
            label: "Personalangebote", 
            value: STATISTIKEN.annoncen .personalangebote 
        } 
    ]; 
    const width = 700; 
    const height = 500; 
    const radius = 
        Math.min(width, height) / 2 - 50; 
        
    const svg = 
        d3.select(container) 
            .append("svg") 
            .attr("width", width) 
            .attr("height", height) 
            .attr( "viewBox", `0 0 ${width} ${height}` ) 
            .attr( "preserveAspectRatio", "xMidYMid meet" ); 
    const chart = 
        svg.append("g") 
            .attr( 
                "transform", 
                `translate(${width / 2},${height / 2})` 
            ); 
    /* * Farbskala */ 
    const color =
    d3.scaleOrdinal()
        .domain(
            data.map(function (d) {
                return d.label;
            })
        )
        .range([
            "#7A263A",
            "#D8B65A"
        ]);
    /* * Pie-Generator */ 
    const pie = 
        d3.pie() 
            .sort(null) 
            .value(function (d) { 
                return d.value; 
            }); 
    /* * Arc-Generator */ 
    const arc = 
        d3.arc() 
            .innerRadius(0) 
            .outerRadius(radius); 
    /* * Bögen erzeugen */ 
    const slices = 
        chart.selectAll(".pie-slice") 
            .data(pie(data)) 
            .enter() 
            .append("path") 
            .attr("class", "pie-slice") 
            .attr("d", arc) 
            .attr("fill", function (d) { 
                return color(d.data.label); 
            }) 
            .attr("stroke", "white") 
            .attr("stroke-width", 2); 
    /* * Tooltip */ 
    slices 
        .on("mouseover", function (event, d) { 
            const total = 
                d3.sum( data, 
                    function (item) { 
                        return item.value; 
                } 
            ); 
            const percentage = 
                total > 0 
                    ? ( 
                        d.data.value / 
                        total * 100 
                    ).toFixed(1) 
                    : 0; 
            tooltip 
                .style("opacity", 1) 
                .html( 
                    "<strong>" + 
                    d.data.label + 
                    "</strong><br>" + 
                    d.data.value + 
                    " Annoncen (" + 
                    percentage + 
                    " %)" 
                ); 
            }) 
            .on("mousemove", 
                function (event) { 
                    tooltip 
                        .style("left", 
                            (event.pageX + 15) + 
                            "px" 
                        ) 
                        .style("top", 
                            (event.pageY - 30) + 
                            "px" 
                        ); 
                    }) 
                    .on("mouseout", function () { 
                        tooltip 
                            .style("opacity", 0); 
                        }); 
    /* * Legende */ 
    const legend = 
        d3.select(container) 
            .append("div") 
            .attr( 
                "class", "chart-legend" 
            ); 
        data.forEach(function (d) { 
            const item = 
                legend.append("div") 
                    .attr( 
                        "class", 
                        "legend-item" 
                    ); 
            item.append("span") 
                .attr( 
                    "class", 
                    "legend-symbol" 
                ) 
                .style( 
                    "background-color", 
                    color(d.label) 
                ); 
            item.append("span") 
                .text( 
                    d.label + 
                    " (" + 
                    d.value + 
                    ")" 
                ); 
            }); 
        } 
   
    function createAnstellungsdatenChart() { 
        const container = 
            document.getElementById( 
                "chart-anstellungsdaten" 
            ); 
        if (!container) { 
            return; 
        } 
        const data = 
            STATISTIKEN.anstellungsdaten; 
    /* * Falls keine gültigen Anstellungsdaten * vorhanden sind. */ 
        if (!data || data.length === 0) { 
            d3.select(container) 
                .append("p") 
                .attr( 
                    "class", 
                    "text-muted" 
                ) 
                .text( 
                    "Es wurden keine genauen Anstellungsdaten gefunden." 
                ); 
            return; 
        } 
    /* * Daten nach Häufigkeit sortieren */ 
    data.sort(function (a, b) { 
        return d3.descending( 
            a.anzahl, b.anzahl 
        ); 
    }); 
    const width = 700; 
    const height = 600; 
    const radius = 
        Math.min(width, height) / 2 - 50; 
    const svg = 
        d3.select(container) 
            .append("svg") 
            .attr("width", width) 
            .attr("height", height) 
            .attr( 
                "viewBox", 
                `0 0 ${width} ${height}` 
            ) 
            .attr( 
                "preserveAspectRatio", 
                "xMidYMid meet" 
            ); 
    const chart = 
        svg.append("g") 
            .attr( 
                "transform", 
                `translate(${width / 2},${height / 2})` 
            ); 
    /* * Farbskala */ 
    const color =
    d3.scaleOrdinal()
        .range([
            "#7A263A",
            "#D8B65A",
            "#8A8A83",
            "#D9C7A3",
            "#5E1D2C",
            "#f8df73",
            "#f8cb03b6",
            "#9a8a42",
            "#f84b73d2",
            "#320a14",
            "#961533",
            "#6d6d68",
            "#474745"
        ]); 
    /* * Pie-Generator */ 
    const pie = 
        d3.pie() 
            .sort(null) 
            .value(function (d) { 
                return d.anzahl; 
            }); 
    /* * Arc-Generator */ 
    const arc = 
        d3.arc() 
            .innerRadius(0) 
            .outerRadius(radius); 
    /* * Bögen */ 
    const slices = 
        chart.selectAll(".pie-slice") 
            .data(pie(data)) 
            .enter() 
            .append("path") 
            .attr( 
                "class", 
                "pie-slice" 
            ) 
            .attr( 
                "d", 
                arc 
            ) 
            .attr( 
                "fill", 
                function (d, i) { 
                    return color(i); 
                } 
            ) 
            .attr( 
                "stroke", 
                "white" 
            ) 
            .attr( 
                "stroke-width", 
                2 
            ); 
        /* * Tooltip */ 
        slices 
            .on("mouseover", function (event, d) { 
                const total = 
                    d3.sum( 
                        data, 
                        function (item) { 
                            return item.anzahl;                     
                        } 
                    ); 
                const percentage = 
                    total > 0 
                    ? ( 
                        d.data.anzahl / 
                        total * 
                        100 
                    ).toFixed(1) 
                    : 0; 
            tooltip 
                .style( 
                    "opacity", 
                    1 
                ) 
                .html( 
                    "<strong>" + 
                    d.data.datum + 
                    "</strong><br>" + 
                    d.data.anzahl + 
                    " Annonce" + 
                    ( 
                        d.data.anzahl === 1 
                            ? "" : 
                            "n" 
                    ) + 
                    " (" + 
                    percentage + 
                    " %)" 
                ); 
            }) 
            .on("mousemove", function (event) { 
                tooltip 
                    .style( 
                        "left", 
                        (event.pageX + 15) + 
                        "px" 
                    ) 
                    .style( 
                        "top", 
                        (event.pageY - 30) + 
                        "px" 
                    ); 
                }) 
            .on("mouseout", function () { 
                tooltip 
                    .style( 
                        "opacity", 
                        0 
                    ); 
                }); 
        /* * Legende */ 
        const legend = 
            d3.select(container) 
                .append("div") 
                .attr( 
                    "class", 
                    "chart-legend" 
                ); 
            data.forEach(function (d, i) { 
                const item = 
                    legend.append("div") 
                        .attr( 
                            "class", 
                            "legend-item" 
                        ); 
            item.append("span") 
                .attr( 
                    "class", 
                    "legend-symbol" 
                ) 
                .style( 
                    "background-color", 
                    color(i) 
                ); 
            item.append("span") 
                .text( 
                    d.datum + 
                    " (" + 
                    d.anzahl + 
                    ")" 
                ); 
            }); 
        } 
        
        createAnnoncenChart(); 
        createAnstellungsdatenChart(); });