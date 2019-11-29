
// r2d3: https://rstudio.github.io/r2d3

// Controls the shape of diagram and color opacities
var outerPadding = 5;
var labelPadding = 3;
var chordPadding = 0.05;
var arcThickness = 15;
var opacity = 0.6;
var fadedOpacity = 0.01;
var transitionDuration = 25;
//outerRadius = width / 2 - outerPadding,
var outerRadius = height / 2 - 60;
var innerRadius = outerRadius - arcThickness;

// Formating & slicing controls
valueFormat = d3.format(",.0f"),
num_flows = 15, // display top num_flows flows
min_flow = 0; // min migration value displayed

/* R automatically defines SVG
// DOM Elements.
      var svg = d3.select("body").append("svg")
            .attr("width", width)
            .attr("height", height)
*/

// Add group elements for ribbons (arcs) and groups (countries)
svg.attr("id","chordDiagram");
var g = svg.append("g")
          .attr("transform", 
                "translate(" + width / 2 + "," + height / 2 + ")");
var ribbonsG = g.append("g");
var groupsG = g.append("g");

/* No space for title
// Add chord title
svg.append("text")
  .attr("x", (width / 2))             
  .attr("y", 30)
  .attr("text-anchor", "middle")  
  .style("font-size", "25px") 
  .text("Human Migration Visualization");
*/

// D3 layouts, shapes and scales.
var ribbon = d3.ribbon()
      .radius(innerRadius);

var chord = d3.chord()
      .padAngle(chordPadding)
      .sortSubgroups(d3.descending);
      
var arc = d3.arc()
      .innerRadius(innerRadius)
      .outerRadius(outerRadius);

var color = d3.scaleOrdinal()
                .range(d3.schemeCategory20);
               /*  //changed color range
                .range(["#000000", "#FFDD89", "#957244", "#F26223"]);
              */

// Define the div for the tooltip
// Added style here but ideally should be in seperate CSS file
var div = d3.select("body").append("div") 
    .attr("class", "tooltip")     // style in CSS file    
    .style("opacity", 0)
    .style("position", 'absolute')
    .style("text-align", 'center')
    .style("background", "grey")
    .style("color", "white")
    .style("line-height", 1)
    .style("padding", "0.5px")
    .style("border-radius", "1px")
    .style("width", '100px')
    .style("height", '30px')
    .style("font", '10px sans-serif');
    


// Renders the given data as a chord diagram.
function render(data){
  //console.log('inside render');
  //names = []; // PURPOSE?
  
  var matrix = generateMatrix(data);
  var chords = chord(matrix);
  color.domain(matrix.map(function (d, i){
    return i;
  }));
  
  // Render the ribbons
  ribbonsG.selectAll("path")
      .data(chords)
    .enter().append("path")
      .attr("class", "ribbon")
      .attr("d", ribbon)
      .style("fill", function(d) {
        //console.log('color_source',d.source.index);
        return color(d.source.index);
      })
      .style("stroke", function(d) {
        return d3.rgb(color(d.source.index)).darker();
      })
      .style("opacity", opacity)
      
  // Render the tooltips
  ribbonsG.selectAll("path")
      .on("mouseenter", function(d){
        // Set src and tgt values
        var src = matrix.names[d.source.index];
        var tgt = matrix.names[d.target.index];
        var src_flow = valueFormat(d.source.value);
        var tgt_flow = 0;
        if (valueFormat(d.target.value) == 0){       
            tgt_flow = "<"+min_flow;
        } else {
            tgt_flow = valueFormat(d.target.value);
        }
        
        // Display tooltip
        div.transition()		
                .duration(200)		
                .style("opacity", 0.9);
            
        div.html("<strong>" + src +" -> " + tgt + ": " + src_flow +
                "<br>" + tgt + " -> " + src + ": " + tgt_flow + "</strong>")
            .style("left", (d3.event.pageX) + "px")   
            .style("top", (d3.event.pageY - 28) + "px"); 
            
      })
      // Hide tooltips
      .on("mouseleave", function (d){
        div.transition()    
          .duration(transitionDuration)    
          .style("opacity", fadedOpacity);
      });
      
 
  // Scaffold the chord groups.
  var groups = groupsG
    .selectAll("g")
      .data(chords.groups)
    .enter().append("g");
    
  // Render the chord group arcs.
  groups
    .append("path")
      .attr("class", "arc")
      .attr("d", arc)
      .style("fill", function(group) {
        return color(group.index);
      })
      .style("stroke", function(group) {
        return d3.rgb(color(group.index)).darker();
      })
      .style("opacity", opacity)
      .call(groupClick);
  // Render the chord group labels.
  var angle = d3.local(),
      flip = d3.local();
  
  // Add country names to groups
  groups
    .append("text")
      .each(function(d) {
        angle.set(this, (d.startAngle + d.endAngle) / 2);
        flip.set(this, angle.get(this) > Math.PI);
      })
      .attr("transform", function(d) {
        return [
          "rotate(" + (angle.get(this) / Math.PI * 180 - 90) + ")",
          "translate(" + (outerRadius + labelPadding) + ")",
          flip.get(this) ? "rotate(180)" : ""
        ].join("");
      })
      .attr("text-anchor", function(d) {
        return flip.get(this) ? "end" : "start";
      })
      .text(function(d) {
        return abbToName[matrix.names[d.index]];
      })
      .attr("alignment-baseline", "central")
      .style("font-family", '"Helvetica Neue", Helvetica')
      .style("font-size", "6pt")
      .call(groupClick);
      
      // Variables to keep track of which source and target have been selected
      var selected_src = -1;
      var selected_tgt = -1;

      // Sets up sequntial group clicking functionality
      // User can select source and target countries
      function groupClick(selection){
        selection
          .on("click", function (group){
            // Dim opacities if user selects group
            g.selectAll(".ribbon")
                .filter(function(ribbon) {
                  return (
                    (ribbon.source.index !== group.index) &&
                    (ribbon.target.index !== group.index)
                  );
                })
              .transition().duration(transitionDuration)
                .style("opacity", fadedOpacity);

            // if src isn't selected, select src
            if (selected_src == -1){
              selected_src = matrix.names[group.index];
              //console.log("Selected source: ", selected_src);
              
            // if src is selected and tgt isn't selected, select tgt
            } else if (selected_tgt == -1){
              selected_tgt = matrix.names[group.index];
              //console.log("Selected target: ", selected_tgt);
              
              Shiny.setInputValue(
                "source_target",
                [selected_src, selected_tgt],
                {priority: "event"}
                );
              
                
            // if both src and tgt and defined, unselect all
            } else {
              selected_src = -1;
              selected_tgt = -1;
              //console.log("unselected source and target");
              // Tell shiny countries have been unselected
              Shiny.setInputValue(
                "both_unselected",
                 -1,
                {priority: "event"}
                );
              // Reset opacities to normal once countries are unselected
              g.selectAll(".ribbon")
                  .transition().duration(transitionDuration)
                  .style("opacity", opacity);
            }
          })
          /* Remove db click to make things less confusing
          Now the only way to clear the chart is 3 clicks
          .on("dblclick", function (){
        
            g.selectAll(".ribbon")
              .transition().duration(transitionDuration)
                .style("opacity", opacity);
          });
          */
      }
}
  
// Generates a matrix (2D array) from the given data, which is expected to
// have fields {origin, destination, count}. The matrix data structure is required
// for use with the D3 Chord layout.

//var names = []; PURPOSE?
function generateMatrix(data){
  var nameToIndex = {},
      names = [],
      matrix = [],
      n = 0, i, j;
      
  function recordName(name){
    if( !(name in nameToIndex) ){
      nameToIndex[name] = n++;
      names.push(name);
    }
  }
  data.forEach(function (d){
    recordName(d.src_abb);
    recordName(d.tgt_abb);
  });
  for(i = 0; i < n; i++){
    matrix.push([]);
    for(j = 0; j < n; j++){
      matrix[i].push(0);
    }
  }
  data.forEach(function (d){
    i = nameToIndex[d.src_abb];
    j = nameToIndex[d.tgt_abb];
    matrix[i][j] = d.flow_prediction;
  });
  matrix.names = names;
  return matrix;
}

// Country abbtextations to full name (used in tooltip)
var abbToName = {
  'AFG' : 'Afghanistan',
  'AGO' : 'Angola',
  'ALB' : 'Albania',
  'ARG' : 'Argentina',
  'ARM' : 'Armenia',
  'AUS' : 'Australia',
  'AUT' : 'Austria',
  'AZE' : 'Azerbaijan',
  'BDI' : 'Burundi',
  'BEL' : 'Belgium',
  'BEN' : 'Benin',
  'BFA' : 'Burkina Faso',
  'BGD' : 'Bangladesh',
  'BGR' : 'Bulgaria',
  'BHR' : 'Bahrain',
  'BLR' : 'Belarus',
  'BRA' : 'Brazil',
  'BWA' : 'Botswana',
  'CAF' : 'Ctrl African Rep.',
  'CAN' : 'Canada',
  'CHE' : 'Switzerland',
  'CHL' : 'Chile',
  'CHN' : 'China',
  'CMR' : 'Cameroon',
  'COD' : 'Rep. of Congo',
  'COL' : 'Colombia',
  'CRI' : 'Costa Rica',
  'CUB' : 'Cuba',
  'CYP' : 'Cyprus',
  'CZE' : 'Czechia',
  'DEU' : 'Germany',
  'DJI' : 'Djibouti',
  'DNK' : 'Denmark',
  'DOM' : 'Dom. Republic',
  'DZA' : 'Algeria',
  'ECU' : 'Ecuador',
  'EGY' : 'Egypt',
  'ERI' : 'Eritrea',
  'ESP' : 'Spain',
  'EST' : 'Estonia',
  'ETH' : 'Ethiopia',
  'FIN' : 'Finland',
  'FRA' : 'France',
  'GEO' : 'Georgia',
  'GHA' : 'Ghana',
  'GIN' : 'Guinea',
  'GNB' : 'Guinea-Bissau',
  'GRC' : 'Greece',
  'GTM' : 'Guatemala',
  'HND' : 'Honduras',
  'HRV' : 'Croatia',
  'HTI' : 'Haiti',
  'IDN' : 'Indonesia',
  'IND' : 'India',
  'IRQ' : 'Iraq',
  'ISR' : 'Israel',
  'ITA' : 'Italy',
  'JOR' : 'Jordan',
  'JPN' : 'Japan',
  'KAZ' : 'Kazakhstan',
  'KEN' : 'Kenya',
  'KHM' : 'Cambodia',
  'KWT' : 'Kuwait',
  'LBN' : 'Lebanon',
  'LBY' : 'Libya',
  'LKA' : 'Sri Lanka',
  'LSO' : 'Lesotho',
  'LTU' : 'Lithuania',
  'LUX' : 'Luxembourg',
  'LVA' : 'Latvia',
  'MAR' : 'Morocco',
  'MDG' : 'Madagascar',
  'MEX' : 'Mexico',
  'MKD' : 'N. Macedonia',
  'MLI' : 'Mali',
  'MNG' : 'Mongolia',
  'MOZ' : 'Mozambique',
  'MRT' : 'Mauritania',
  'MWI' : 'Malawi',
  'MYS' : 'Malaysia',
  'NAM' : 'Namibia',
  'NER' : 'Niger',
  'NGA' : 'Nigeria',
  'NIC' : 'Nicaragua',
  'NLD' : 'Netherlands',
  'NPL' : 'Nepal',
  'NZL' : 'New Zealand',
  'OMN' : 'Oman',
  'PAK' : 'Pakistan',
  'PAN' : 'Panama',
  'PER' : 'Peru',
  'PHL' : 'Philippines',
  'PNG' : 'Papua New Guinea',
  'POL' : 'Poland',
  'PRT' : 'Portugal',
  'PRY' : 'Paraguay',
  'QAT' : 'Qatar',
  'ROU' : 'Romania',
  'RWA' : 'Rwanda',
  'SAU' : 'Saudi Arabia',
  'SEN' : 'Senegal',
  'SLE' : 'Sierra Leone',
  'SLV' : 'El Salvador',
  'SVK' : 'Slovakia',
  'SVN' : 'Slovenia',
  'SWE' : 'Sweden',
  'TCD' : 'Chad',
  'THA' : 'Thailand',
  'TJK' : 'Tajikistan',
  'TKM' : 'Turkmenistan',
  'TUN' : 'Tunisia',
  'TUR' : 'Turkey',
  'UGA' : 'Uganda',
  'UKR' : 'Ukraine',
  'UZB' : 'Uzbekistan',
  'ZAF' : 'South Africa',
  'ZMB' : 'Zambia',
  'ZWE' : 'Zimbabwe',
}

// Update chord once new data comes in
function updateChord(data){
  // Remove existing SVG
  svg.selectAll("g")
              .remove();
  // Render new chords with new data
  g = svg.append("g")
            .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")"),
  ribbonsG = g.append("g"),
  groupsG = g.append("g");
  render(data);
  
}

// Initialize chord
if(data["year"] == 1970){
  render(data);
}else{
  updateChord(data);
}

/* Ideally add to CSS file
div.tooltip { 
    position: absolute;     
    text-align: center;     
    width: 100px;          
    height: 65px;         
    padding: 4px;       
    font: 9px sans-serif;    
    background: white; 
    border: 0px;    
    border-radius: 3px;     
    pointer-events: none; 
}
*/