# 🚀 Consuming Customer Specific Datasets from Data Sharing Partners | [GSP1043 Lab Guide](https://www.cloudskillsboost.google/focuses/42015?parent=catalog)

## 🔐 Master Data Sharing Workflows Across Multiple GCP Projects

### 📽️ Solution Video 👉 [GSP1043 Lab Guide](https://youtu.be/Qb3JYr_syG0)

---

## 🛠️ One-Click Lab Setup — Run These in Cloud Shell

This lab requires executing commands in three different project consoles. Open each project in a separate browser tab and run the corresponding commands.

---

## ✅ Step-by-Step Lab Procedure

✅ **1. Set Up the Data Sharing Partner Project**  
This step configures the environment for the data sharing partner who will control access to data.  
Run these commands in the Data Sharing Partner Project console:

```bash
curl -LO https://raw.githubusercontent.com/sampathiraosidharth/Google-Cloud-Arcade---2025/refs/heads/main/Level%201%3A%20Application%20Development%20and%20Security%20with%20GCP/Build%20and%20Automate/GSP1043%20Consuming%20Customer%20Specific%20Datasets%20from%20Data%20Sharing%20Partners%20using%20BigQuery/Setup.sh

sudo chmod +x *.sh

./*.sh
```

✅ **2. Configure the Data Publisher Project**  
Now let's set up the project that publishes the actual datasets to be shared.  
Run these commands in the Data Publisher Project console:

```bash
curl -LO https://raw.githubusercontent.com/sampathiraosidharth/Google-Cloud-Arcade---2025/refs/heads/main/Level%201%3A%20Application%20Development%20and%20Security%20with%20GCP/Build%20and%20Automate/GSP1043%20Consuming%20Customer%20Specific%20Datasets%20from%20Data%20Sharing%20Partners%20using%20BigQuery/Customer%20Project.sh

sudo chmod +x *.sh

./*.sh
```

✅ **3. Set Up the Customer (Data Twin) Project**  
Finally, configure the consumer project that will access the shared data.  
Run these commands in the Customer (Data Twin) Project console:

```bash
curl -LO https://raw.githubusercontent.com/sampathiraosidharth/Google-Cloud-Arcade---2025/refs/heads/main/Level%201%3A%20Application%20Development%20and%20Security%20with%20GCP/Build%20and%20Automate/GSP1043%20Consuming%20Customer%20Specific%20Datasets%20from%20Data%20Sharing%20Partners%20using%20BigQuery/Configure.sh

sudo chmod +x *.sh

./*.sh
```

---

## 🧪 Optional Experimentation  
Try extending your understanding of BigQuery data sharing with these activities:

1. Run analytics queries across the shared datasets to extract insights
2. Explore the BigQuery UI to verify data access permissions
3. Try modifying sharing permissions to see how it affects data access
4. Check the audit logs to see the data access patterns:

```bash
gcloud logging read "resource.type=bigquery_dataset AND protoPayload.methodName=google.cloud.bigquery.v2.TableService.InsertTable" --limit=10 --format=json
```

---

# 🎯 Mission Accomplished!  
You've completed the lab and learned how to implement cross-project data sharing in BigQuery 🚀  
You're officially closer to mastering BigQuery's enterprise data sharing capabilities! 🌩️

---

## 📋 Lab Success Checklist  
- [ ] Data Sharing Partner project scripts executed successfully
- [ ] Data Publisher project scripts executed successfully
- [ ] Customer (Data Twin) project scripts executed successfully
- [ ] Verified data sharing permissions are working correctly
- [ ] Ran test queries to confirm data access

---


## 🔗 Let's Connect and Grow Together

Hi, I'm **Sidharth**, passionate about helping students and developers!  
Stay connected for more such 🔥 labs, walkthroughs, and exclusive guides:

- 🔗 [LinkedIn](https://www.linkedin.com/in/sampathi-sidharth/)
- 📸 [Instagram](https://www.instagram.com/sampathi_rao_sidharth/)
- 📺 [YouTube – QuickPySidharth](https://www.youtube.com/@QuickPySidharth)


---

### 💡 Follow [QuickPySidharth](https://www.youtube.com/@QuickPySidharth) – For Weekly Dev Shortcuts & Deep Dives!
From GCP labs to automation tricks — crisp content, no fluff.  
**Subscribe now, thank yourself later.** ✅