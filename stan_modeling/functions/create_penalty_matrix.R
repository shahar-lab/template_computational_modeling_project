create_penalty_matrix <- function(x_vals, basis_matrix) {
  n_grid <- length(x_vals)
  n_basis <- ncol(basis_matrix)
  
  #Compute second derivatives using finite differences
  D <- matrix(0, n_grid - 2, n_basis)
  for (i in 2:(n_grid - 1)) {
    for (j in 1:n_basis) {
      D[i-1, j] <- (basis_matrix[i-1, j] - 2*basis_matrix[i, j] + basis_matrix[i+1, j])
    }
  }
  
  #Compute penalty matrix
  S <- t(D) %*% D
  
  return(S)
}