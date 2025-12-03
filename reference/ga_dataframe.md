# Get google analytics data as a dataframe

This function retrieves Google Analytics data and returns it as a
dataframe.

## Usage

``` r
ga_dataframe(property_id, start_date, end_date, metrics, dimensions)
```

## Arguments

- property_id:

  The Google Analytics Property ID (e.g., "2839410283").

- start_date:

  The start date for the data retrieval (e.g., "2023-01-01").

- end_date:

  The end date for the data retrieval (e.g., "2023-01-31").

- metrics:

  The metrics to retrieve (e.g., "ga:sessions,ga:pageviews").

- dimensions:

  The dimensions to retrieve (e.g., "ga:date,ga:source").

## Value

A dataframe containing the Google Analytics data.
