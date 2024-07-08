# GitOps

The foundation for using the automated deployment tools. Enables automated versioning using git

## Key factors
We have to keep some factors in mind:
- Don't store secrets in the repository - use nomad variables or ansible vault
- Applies the complete configuration on push to the `main` branch and only if the commit message begins with `apply:`. Anything else will just build the documentation