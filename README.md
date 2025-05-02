## Screenshot

![MyWeather App Screenshot](./assets/ottawacityweather.png)

## MyWeather App

MyWeather App is a containerized microservice application featuring a React frontend, a backend openweather, Google Gemini Weather API for city weather summerzinig as part of my personal project both for fun and to demonstrate Devops and microservice application development skill and this Respository demonstrates how to set up the application locally using Docker Compose and showcases a CI/CD pipeline for automated building, testing, and integration.

## Architecture

Initial Architecture, Thanks to the sample react application from freecodecamp.org

![Initial Architecture Screenshot](./assets/Initial-monolithic-architecture.jpg)

Later after continous learning, patience and effort. I have converted thiis monolithic application into microservice application and also added some 
features like Free Google Gemini Weather Summerizer within 25 words based on the city which is searched on the Frontend application usings its API from GCP Google Cloud all along with the Free openweather API to fetch specific city weather patterns.

## Final Architecture

Later after continous learning, patience and effort. I have converted thiis monolithic application into microservice application and also added some 
features like  
Google Gemini Weather Summerizer within 25 words based on the city which is searched on the Frontend application usings its API from GCP Google Cloud and next 24 hours weather Chart Graph.

![Final Architecture Screemshot](./assets/Updated-microservice-architecturewith-Infra-automation.jpg)

## Prerequisites

- Docker
- Docker Compose
- AWS CLi
- Terraform 
- Openweather API
- Gemini API

## Environment Variables

update the `.env` file in the root of your project to store your environment variables:

```plaintext
REACT_APP_GEO_API_URL=https://wft-geo-db.p.rapidapi.com/v1/geo
REACT_APP_RAPIDAPI_KEY=<your key>
REACT_APP_RAPIDAPI_HOST=wft-geo-db.p.rapidapi.com

WEATHER_API_URL=https://api.openweathermap.org/data/2.5
WEATHER_API_KEY=<your key>
```

## Docker Compose

### Create the AWS Cloud Infrastructure and download/build and start the application.

I have used Github actions to initially do the CI-CD pipeline work along with Terraform integration to seemlessly deploy the required Infrastructure on the AWS Cloud starting with initializing Terraform script and creating Terraform state services on AWS S3 and DynamoDB to secure its state file and then create the Infrastructure and then deploy the application code from the Github respository and install docker-compose and build/start the microservice container application using docker-compose.

## Services

### React Frontend

The React frontend is served on port 3000. It uses environment variables to configure the API URLs and headers.

## Sample Application weather Search
![weather Screenshot1](./assets/Cityweather-search1.png)

![weather Screenshot2](./assets/Cityweather-search2.png)

### Backend Server

The backend server is served on port 5001. It uses environment variables to configure the Redis and PostgreSQL connections, as well as the OpenWeatherMap API.

### Prometheus

Prometheus is used for monitoring and scraping metrics from the backend, Redis, and PostgreSQL services. It is accessible on port 9090.

- **Configuration**: The Prometheus configuration file (`prometheus.yml`) is mounted into the container.
- **Metrics Endpoint**: Prometheus scrapes metrics from the `/metrics` endpoint exposed by the backend service.

### Grafana

Grafana is used for visualizing metrics collected by Prometheus. It is accessible on port 3001.

- **Default Credentials**:
  - Username: `admin`
  - Password: `admin` (or the value set in the `GF_SECURITY_ADMIN_PASSWORD` environment variable).
- **Prometheus Data Source**:
  - URL: `http://prometheus:9090`
  - URL: `http://loki:3100`
  - I have created and already imported the json file for view prometheus and Loki based dashboard on Grafana to monitoring the container metrics and errors via Grafana dashboard.

  Prometheus datasource based dashboard
  ![Final Architecture Screemshot](./assets/Grafana-complete-containers-dashboard.jpg)

  Loki datasource based dashboard
  ![Final Architecture Screemshot](./assets/Logs-monitoring.jpg)

## Example PromQL Queries

Here are some example PromQL queries you can use in Grafana to visualize metrics:

- **Total HTTP Requests**:
  ```promql
  sum(rate(http_request_count[1m]))
  ```

- **Average Request Duration**:
  ```promql
  rate(http_request_duration_ms_sum[1m]) / rate(http_request_duration_ms_count[1m])
  ```

- **95th Percentile Request Duration**:
  ```promql
  histogram_quantile(0.95, sum(rate(http_request_duration_ms_bucket[1m])) by (le))
  ```

## Additional Information

### CI/CD Pipeline

This repository includes a demonstration CI/CD pipeline (e.g., using GitHub Actions, GitLab CI, etc. - *adjust based on your specific implementation*). The pipeline automates the following steps:

1.  **Linting & Formatting**: Checks the codebase for style consistency and potential errors (e.g., using linters like ESLint for the frontend and Ruff/Flake8 for the backend).
2.  **Testing**: Executes automated tests (unit, integration) to ensure code quality and functionality.
3.  **Docker Image Building**: Builds Docker images for the application services (frontend, backend).
4.  **Docker Image Pushing**: Pushes the built images to a container registry (e.g., Docker Hub, GitHub Container Registry).
5.  **(Optional) Deployment**: Deploys the application to a target environment (this step might vary depending on the specific demo setup).

Refer to the pipeline configuration file (e.g., `.github/workflows/ci.yml`) in the repository for the exact implementation details.

---

### Environment File Security

Ensure that the `.env` file is not committed to version control by adding it to your `.gitignore` file:

```plaintext
# .gitignore
.env
```

This will help keep your sensitive information secure.
```

### Summary:
1. **Environment Variables**: Create a .env file to store environment variables.
2. **Docker Compose Commands**: Include commands to start and stop the application using Docker Compose.
3. **Services**: Describe the services (React frontend, Redis, PostgreSQL, backend server) and their configurations.
4. **Logging**: Explain the logging configuration.
5. **Additional Information**: Ensure the .env file is not committed to version control.

These updates to the README.md file will provide clear instructions on how to set up and run the application, as well as how to manage environment variables and logging.
