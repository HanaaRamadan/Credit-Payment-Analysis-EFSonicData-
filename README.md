# EFSonic_-credit-payment-details

📌 Query: Credit & Payment Analysis (EFSonicData)

Description
This query provides a detailed accounts receivable and credit control report. It shows customers’ invoices, payments, outstanding balances, credit terms, overdue days, and monthly credit violations.

Parameters

@Language → to display customer names, employee names, and sales territories in the selected language.

Key Features

Retrieves customer & sales rep details.

Displays credit terms: credit limit & credit period.

Shows invoice details: invoice number, value, date, due date.

Tracks collections: applied payments, last payment date, and payment dates.

Calculates:

Current balance per invoice.

Due date = Transaction date + Credit period.

Days overdue (if payment exceeded due date).

Monthly credit violations (count of overdue invoices within the month).

Uses ROW_NUMBER() to avoid duplicate balances (shows only current balance once).

Output Columns

Sales rep name.

Sales sector (organization).

Customer code & name.

Credit limit & credit period.

Invoice ID & value.

Invoice date & due date.

Collections (payment amount, payment date, last payment date).

Current balance (only for first ranked row per invoice).

Days overdue.

Monthly overdue count.

Use Case
✅ Useful for credit control teams to monitor overdue accounts.
✅ Helps sales & finance track customer payment behavior.
✅ Supports risk management by identifying customers exceeding credit limits or terms.
