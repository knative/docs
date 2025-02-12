
# Knative Bookstore Tutorial - Solution Directory

Welcome to the solution directory of the Knative Bookstore tutorial. This directory contains the fully implemented version of the event-driven bookstore application using Knative.

You can find the tutorial for this solution [here](https://knative.dev/docs/bookstore/page-0/welcome-knative-bookstore-tutorial/).

## Directory Structure

Here's an overview of the components in the solution:

- `bad-word-filter/`: Knative Function for filtering out inappropriate content
- `db-service/`: Database service for storing book reviews and comments
- `frontend/`: User interface for the bookstore application built with Next.js
- `node-server/`: Node.js server for handling backend operations
- `sentiment-analysis-app/`: Knative Function for analyzing the sentiment of book reviews
- `sequence/`: Knative Sequence setup for orchestrating workflows
- `slack-sink/`: Integration with Slack for notifications with Apache Camel

## Additional Files

- `setup.sh`: Script for setting up the required services including installing Knative, frontend, and backend node-server
- `solution.sh`: Script for installing everything, deploying the entire solution. **It includes the setup script as well.**

## Running the Solution

1. Have a running Kubernetes cluster.
2. Install all the prerequisites and deploy the entire solution using the `solution.sh` script:
   ```
   ./solution.sh
   ```
If you encountered any permission issues, run the following command:
   ```
   chmod +x solution.sh
   ```

## Next Steps

- Explore each component to understand how they work together in an event-driven architecture.
- Compare this solution with your own implementation if you've completed the tutorial.
- Experiment with modifying or extending the solution to add new features.

## Need Help?

If you encounter any issues or have questions about the solution, refer to the main tutorial documentation or reach out to the Knative community for support.
