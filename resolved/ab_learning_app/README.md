### Development demo accounts

When `SEED_DEV=true`, the API creates development accounts
with the following credentials:

| Role | Email |
|---|---|
| Learner | learner@ablearning.co |
| Instructor | instructor@ablearning.co |
| Corporate Admin | corpadmin@ablearning.co |
| Corporate Manager | corpmanager@ablearning.co |
| Employer | employer@ablearning.co |
| Admin | admin@ablearning.co |

Password for all development accounts: `Password123!`

Do not enable development seeding in staging or production.

- Media uploads currently use local filesystem storage.
- Payment refunds are recorded by the API; actual payment gateway
  money movement is not implemented by this refund flow.
- The Flutter app still uses `MockRepository` and is not yet
  fully integrated with the Go API.