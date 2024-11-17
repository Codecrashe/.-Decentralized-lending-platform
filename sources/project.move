module Decentralizedlendingplatform ::LendingPlatform {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a loan.
    struct Loan has store, key {
        amount: u64,      // Amount of the loan
        repaid: bool,     // Status of the loan repayment
    }

    /// Function to create a new loan.
    public fun create_loan(lender: &signer, amount: u64) {
        let loan = Loan {
            amount,
            repaid: false,
        };
        move_to(lender, loan);
        
        // Transfer the loan amount from the lender to the borrower
        let loan_amount = coin::withdraw<AptosCoin>(lender, amount);
        coin::deposit<AptosCoin>(signer::address_of(lender), loan_amount);
    }

    /// Function for the borrower to repay the loan.
    public fun repay_loan(borrower: &signer) acquires Loan {
        let loan = borrow_global_mut<Loan>(signer::address_of(borrower));
        assert!(!loan.repaid, 1); // Ensure the loan hasn't been repaid

        // Transfer the repayment amount from the borrower to the lender
        let repayment_amount = loan.amount;
        let repayment = coin::withdraw<AptosCoin>(borrower, repayment_amount);
        coin::deposit<AptosCoin>(signer::address_of(borrower), repayment);

        loan.repaid = true; // Mark the loan as repaid
    }
}