
## ⚠️ Disclaimer

If you’re new to scripting, **you cannot use display names** for account names — you must use the actual **username**.

This setup requires **multiple accounts running at the same time**.

---

## 🧰 Recommended Tools

### 🔹 Fishstrap (Multi-account launcher)

Used to run multiple Roblox clients simultaneously.

**Download:**
[https://github.com/fishstrap/fishstrap/releases](https://github.com/fishstrap/fishstrap/releases)
➡ Download **Fishstrap.exe** from the latest release.

**Enable multi-instance:**
`Settings → Bootstrapper → Miscellaneous → Enable Multiple Instances`

---

### 🔹 Xeno (Recommended Executor)

[https://www.xeno.onl/](https://www.xeno.onl/)

---

## ⚙️ Setup Guide

### 1️⃣ Configure account names

Open **`main.lua`** and replace each placeholder with your account usernames.

* Comments in the file indicate which account goes where.
* There are **two sets of Red, Blue, and Purple** for **200% Purple**.

  * If you don’t need this, you can use just the first three.

---

### 2️⃣ Set your main account

Locate:

```
_G.MAIN_USER_NAME
```

Replace it with the username of the account you want to **control abilities from**.

---

### 3️⃣ Inject & run

1. Launch all accounts.
2. Inject into **all clients**.
3. Ensure **all clients are selected**.
4. Execute **main.lua** on all clients.

---

### 4️⃣ Using moves

* Run each move as a **separate script**.
* The system will **automatically determine** which accounts are needed.
* No need to manually select/deselect clients.

---

✅ Once configured, everything runs automatically.

Enjoy.

yes i did use chatgpt to make it look better because not bothered this was like 15 minute side project anyway feel free to skid ig you are entitled for ts script
