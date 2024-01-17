# Personal_Expense_Tracker_SQL
## Overview

This GitHub repository contains SQL scripts to create a database schema for a Personal Expense Tracker. The database is designed to track various expense-related information, including categories, subcategories, expenses, earnings, taxes, and user access control.

## Structure

1. **Database Creation and Use**
   - Created a database named `PersonalExpenseTracker`.
   - Set the database context using `USE PersonalExpenseTracker;`.

2. **Tables**
   - **Category Table:** Represents expense categories.
   - **SubCategory Table:** Represents subcategories associated with categories.
   - **Expense Table:** Stores information about individual expenses, including amount, date, and subcategory.
   - **Earnings Table:** Records earnings with details such as name, amount, and date.
   - **Tax Table:** Manages tax rates associated with categories and subcategories.

3. **User Access Control**
   - Created a user named `limited_user` with limited access rights.

4. **Sample Data Insertion**
   - Inserted sample categories, subcategories, expenses, earnings, and taxes for testing purposes.

5. **Stored Procedures**
   - **GetTotalExpensesAndEarnings:** Retrieves total expenses and earnings for a specified month.
   - **GetTaxesPaidInCategory:** Shows taxes paid in a specific category, broken down by subcategory.
   - **GetSubCategoriesWithNoExpenses:** Identifies subcategories with no recorded expenses.
   - **GetProfitableMonths:** Determines profitable months based on earnings exceeding expenses.

6. **Trigger**
   - **CheckTotalSpending:** Ensures that the total spending for a month does not exceed 50000 Rs.

## Usage

1. Clone the repository to your local machine:

   ```bash
   git clone https://github.com/your-username/PersonalExpenseTracker.git
   ```

2. Execute the SQL scripts on your MySQL database:

   ```bash
   mysql -u username -p < PersonalExpenseTracker.sql
   ```

3. Modify user permissions if needed:

   ```sql
   GRANT SELECT ON PersonalExpenseTracker.Category TO 'limited_user'@'localhost';
   GRANT SELECT ON PersonalExpenseTracker.SubCategory TO 'limited_user'@'localhost';
   GRANT SELECT ON PersonalExpenseTracker.Expense TO 'limited_user'@'localhost';
   -- Repeat for other tables as needed
   ```

4. Explore and use the database with the provided procedures and trigger.

## Additional Notes

- Ensure that your MySQL server is running and accessible.
- Modify the scripts according to your specific requirements.
- For security reasons, consider updating the default passwords and access privileges.

Feel free to contribute, report issues, or suggest improvements to enhance the functionality of the Personal Expense Tracker database.
