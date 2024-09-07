# Wright-DBX-Runtime-Mgr

**Wright**: The Databricks Runtime Manager

This CLI tool helps you manage Python, Scala, Spark, and Java versions locally to mimic specific Databricks runtime environments without spinning up clusters. Use **wright** to create and switch between environments that align with Databricks runtime versions like **10.4**, **11.3**, and beyond.

## Key Features:
- **Install and manage local environments**: Aligns versions of Python, Scala, Spark, and Java to Databricks runtime specifications.
- **Mimic Databricks runtimes**: Run tests and development tasks in your local environment that replicate Databricks clusters.
- **Flexible version control**: Store and switch between environments as needed.

## Usage:
- **Install wright**: 
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/yourusername/wright-dbx-runtime-mgr/main/install_wright.sh)"
  ```
- **Install a runtime environment**:
  ```bash
  wright install databricks-10.4
  ```
- **Activate specific environment**:
  ```bash
  wright activate databricks-11.3
  ```

