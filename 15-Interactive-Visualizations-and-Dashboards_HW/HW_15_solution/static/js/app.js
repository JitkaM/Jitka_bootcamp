function buildMetadata(sample) {

  // @TODO: Complete the following function that builds the metadata panel
  var metadata_url = `/metadata/${sample}`;
  d3.json(metadata_url).then((output) => {
      // console.log(output);
      var metadata_panel = d3.select('#sample-metadata');
      metadata_panel.html("");
      // Use 'Object.entries' to add each key and value pair to the panel
      Object.entries(output).forEach(([key,value])=> {
        metadata_panel.append("j").text(`${key}: ${value}`)
      } ) 
    });
}

function buildCharts(sample) {
// @TODO: Use `d3.json` to fetch the sample data for the plots

  var charts_url = `/samples/${sample}`
  d3.json(charts_url).then((output) => {
    // console.log(output);
       

//https://plot.ly/javascript/bubble-charts/
// @TODO: Build the Bubble Chart
    var trace1 = {
      x: output.otu_ids,
      y: output.sample_values,
      text: output.otu_labels,
      mode: 'markers',
      marker: {
        color: output.otu_ids,
        size: output.sample_values
      } 
    };

    var data = [trace1];

    var layout = {
      xaxis: { title: "OTU ID"},
    };

    Plotly.newPlot('bubble', data, layout);


// @TODO: Build a Pie Chart

    d3.json(charts_url).then((output) => { 

      var data = [{
        values: output.sample_values.slice(0,10),
        labels: output.otu_ids.slice(0,10),
        hovertext: output.otu_labels.slice(0,10),
        type: 'pie'
      }];

      Plotly.newPlot('pie', data);
    });
  });
} // end of function buildCharts(sample)


function init() {
  // Grab a reference to the dropdown select element
  var selector = d3.select("#selDataset");

  console.log(selector)

  // Use the list of sample names to populate the select options
  d3.json("/names").then((sampleNames) => {
    sampleNames.forEach((sample) => {
      selector
        .append("option")
        .text(sample)
        .property("value", sample);
    });

    // Use the first sample from the list to build the initial plots
    const firstSample = sampleNames[0];
    buildCharts(firstSample);
    buildMetadata(firstSample);
  });
}

function optionChanged(newSample) {
  // Fetch new data each time a new sample is selected
  buildCharts(newSample);
  buildMetadata(newSample);
}

// Initialize the dashboard
init();
