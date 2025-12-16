# Create K-Fold Cross Validation Splits

Create K-Fold Cross Validation Splits

## Usage

``` r
create_kfold_splits(data, k = 5, seed = NULL)
```

## Arguments

- data:

  A data frame containing the dataset

- k:

  Number of folds (default: 5)

- seed:

  Random seed for reproducibility (optional)

## Value

A list containing fold assignments for each observation
