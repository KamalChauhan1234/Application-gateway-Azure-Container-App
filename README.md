# Azure Application Gateway + Container App (Terraform)

Deploy an **Azure Application Gateway** with **Azure Container App** as the backend pool — managed via Terraform and GitHub Actions with **dev/prod environment selection**.

---

## 📁 Project Structure

```
.
├── terraform/
│   ├── main.tf                        # Root module (VNet, RG, module calls)
│   ├── variables.tf                   # Input variables
│   ├── outputs.tf                     # Outputs
│   ├── modules/
│   │   ├── app-gateway/               # Application Gateway module
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── container-app/             # Container App module
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── environments/
│       ├── dev/dev.tfvars             # Dev variables
│       └── prod/prod.tfvars           # Prod variables
└── .github/
    └── workflows/
        ├── deploy.yml                 # Main workflow (env selector)
        └── terraform-deploy.yml       # Reusable deploy workflow
```

---

## 🚀 How It Works

### Option 1 — Manual Deploy (Environment Dropdown)
1. Go to **Actions → Terraform Deploy → Run workflow**
2. Select **environment**: `dev` or `prod`
3. Select **action**: `plan`, `apply`, or `destroy`
4. Click **Run workflow**

### Option 2 — Auto Deploy on Push
| Branch | Environment |
|--------|-------------|
| `dev`  | Dev         |
| `main` | Prod        |

---

## ⚙️ Architecture

```
Internet
   │
   ▼
[Public IP]
   │
[Application Gateway]  ← WAF enabled on Prod
   │
   │  (internal VNet)
   ▼
[Azure Container App]
   └── Min replicas: 1 (dev) / 2 (prod)
   └── CPU/Memory: 0.5/1Gi (dev) / 1/2Gi (prod)
```

---

## 🔐 GitHub Secrets Required

Go to **Settings → Secrets → Actions** and add:

### Dev Secrets
| Secret Name | Description |
|---|---|
| `DEV_AZURE_CLIENT_ID` | Service Principal / App Registration Client ID |
| `DEV_AZURE_TENANT_ID` | Azure Tenant ID |
| `DEV_AZURE_SUBSCRIPTION_ID` | Azure Subscription ID |
| `DEV_TF_BACKEND_RESOURCE_GROUP` | RG for Terraform state storage |
| `DEV_TF_BACKEND_STORAGE_ACCOUNT` | Storage account for TF state |
| `DEV_TF_BACKEND_CONTAINER` | Blob container name for TF state |

### Prod Secrets
Same as above but with `PROD_` prefix.

---

## 🛡️ Azure OIDC Setup (No Client Secret Needed!)

```bash
# 1. Create App Registration
az ad app create --display-name "github-terraform-dev"

# 2. Create Service Principal
az ad sp create --id <APP_ID>

# 3. Add Federated Credential (for GitHub Actions)
az ad app federated-credential create \
  --id <APP_ID> \
  --parameters '{
    "name": "github-dev",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:KamalChauhan1234/Application-gateway-Azure-Container-App:ref:refs/heads/dev",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# 4. Assign Contributor role
az role assignment create \
  --assignee <APP_ID> \
  --role Contributor \
  --scope /subscriptions/<SUBSCRIPTION_ID>
```

---

## 🗄️ Terraform State Backend Setup

```bash
# Run once before first deploy
az group create --name rg-tfstate-dev --location "East US"

az storage account create \
  --name stterraformdev001 \
  --resource-group rg-tfstate-dev \
  --sku Standard_LRS

az storage container create \
  --name tfstate \
  --account-name stterraformdev001
```

---

## 🌍 GitHub Environments Setup (Prod Approval Gate)

1. Go to **Settings → Environments**
2. Create environment `prod`
3. Add **Required reviewers** → your GitHub username
4. Now every prod deploy will need manual approval ✅

---

## 🧪 Local Testing

```bash
cd terraform

# Dev
terraform init \
  -backend-config="resource_group_name=rg-tfstate-dev" \
  -backend-config="storage_account_name=stterraformdev001" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=dev/terraform.tfstate"

terraform plan -var-file="environments/dev/dev.tfvars"
terraform apply -var-file="environments/dev/dev.tfvars"

# Prod
terraform plan -var-file="environments/prod/prod.tfvars"
```
