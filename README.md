# free-gcloud

## ☁️ Goal
This project provisions a **Google Cloud free-tier VM** and minimal
infrastructure using **Terraform**. It’s designed to stay within Google’s
[Free Tier](https://cloud.google.com/free/docs/free-cloud-features#free-tier)
limits and serve as a reproducible template for small web or learning projects.

## 🚀 Prerequisites
- **Google Cloud account** with billing *enabled*
- **Free-tier eligibility** which you can check
[here](https://cloud.google.com/free/docs/free-cloud-features#free-tier)
- **Terraform CLI** (v1.12+) installable
[here](https://developer.hashicorp.com/terraform/install)
- **gcloud SDK** (for authentication and `gsutil` commands) installable
[here](https://cloud.google.com/sdk/docs/install)


## ✏️ Configure
Choose your google cloud project:
```bash
export PROJECT_ID=<your-project-name>
gcloud config set project $PROJECT_ID
```

Authenticate:
```bash
gcloud auth login
gcloud auth application-default set-quota-project $PROJECT_ID
```

Terraform needs a backend 🪣 bucket to store its state. These buckets are free up
to 5GB worth of storage, so this should be perfectly within free tier limits.
Run the following script to create a bucket in `us-west1` (one of the free tier
regions):
```bash
bash ./scripts/setup-backend.sh
```

## 🏗️ Deploy the Free-Tier VM
```bash
cd terraform
terraform init
terraform apply --auto-approve \
  -var="project_id=$PROJECT_ID" \
  -var="resource_prefix=$USER"
```

This creates:
- A **VPC network** (free)
- Basic **firewall rules** (free)
- One **e2-micro** VM (Always Free eligible)
- A **pd-standard** disk (HDD ≤ 30 GB)
- Basic **startup script**

After apply completes, Terraform prints:
```
external_ip = "<YOUR_VM_IP>"
http_url    = "http://<YOUR_VM_IP>/"
ssh_command = "gcloud compute ssh <your-vm-name> --zone=us-east1-b"
```
Visit that URL to verify your server (if using the `nginx-server.sh` startup
script).

## 💸 Free-Tier Notes
| Resource | Free Limit | Notes |
|-----------|-------------|-------|
| Compute Engine | 1 × e2-micro (750 hours/month) | us-east1 / us-central1 / us-west1 |
| Persistent Disk | 30 GB (HDD only) | Use `pd-standard` |
| Cloud Storage | 5 GB | Terraform state bucket |
| Egress | 1 GB from VM, 100 GB from GCS | Outbound only |
| Logging/Monitoring | Free | Up to 50 GB logs / 150 MB metrics per project |

## 🧠 Tips
- Keep the VM running to stay under free-tier (stopping/starting resets IP).
- Use **ephemeral IPs** to avoid static IP charges.
- Restrict SSH using your IP CIDR.
- Add billing alerts ($1 budget) in the Cloud Console for peace of mind.

## 🧹 Teardown
To remove everything (except the backend bucket):
```bash
terraform destroy -auto-approve
```
Then manually delete the bucket if desired:
```bash
gsutil rm -r gs://$PROJECT_ID-terraform-state/
```


✅ **Result:** A completely free, secure, and reproducible GCP VM setup managed by Terraform.