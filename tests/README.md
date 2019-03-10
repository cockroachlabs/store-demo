# Tests

## 3/10/19

### GCP east
```
Test Summary
        Test ID: 7hNqTkUz
        Duration: 30
        State: SC
        Region: east
        # Threads: 256
        # Transactions Completed: 3742681
        # Unique Accounts Used: 3742681
        # Accounts Updated: 3742681
        # Update Retries: 1
        # Insert Retries: 3
        # Balances Not Found: 0
        Total Time in MS: 1800230

```

### GCP west
```
Test Summary
        Test ID: Qe35rwUg
        Duration: 30
        State: CA
        Region: west
        # Threads: 256
        # Transactions Completed: 3652971
        # Unique Accounts Used: 3652971
        # Accounts Updated: 3652971
        # Update Retries: 65
        # Insert Retries: 44
        # Balances Not Found: 0
        Total Time in MS: 1800156

```

### Azure central
```
Test Summary
        Test ID: 8FDeHMWK
        Duration: 30
        State: TX
        Region: central
        # Threads: 256
        # Transactions Completed: 2231110
        # Unique Accounts Used: 2231110
        # Accounts Updated: 2231110
        # Update Retries: 30
        # Insert Retries: 10
        # Balances Not Found: 0
        Total Time in MS: 1800229

```
![Screenshot](Fullscreen_3_10_19__6_04_PM.png)

region | completed | update retries | insert retries
------------ | ------------- | ------------- | -------------
east | 3742681 | 1 | 3
west | 3652971 | 65 | 44
central | 2231110 | 30 | 10
total | 9626762 | 96 | 47