# Pub/Sub Notify

This demo receives data via Pub/Sub, then notify the client through Firestore.

## Deploy

### Configure

```sh
cp .envrc.example .envrc
vi .envrc
source .envrc # or use direnv
```

### Apply Terraform

```sh
cd terraform
terraform init
terraform apply
```

### Deploy Backend

```sh
cd backend
git init

# Push backend code to source repository created by terraform in your project
```

### Deploy Frontend

```sh
cd frontend
npm install
npx firebase experiments:enable webframeworks
npx firebase login
npx firebase init hosting
npx firebase deploy
```

## Send data

```sh
cd message_sender
poetry install
poetry run python main.py Ruby starving
poetry run python main.py Ruby fully_fed
poetry run python main.py YourDog starving
```
