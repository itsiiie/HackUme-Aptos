module anonymous_feedback::AnonymousFeedback {
    use aptos_framework::aptos_account;
    use aptos_framework::event;
    use aptos_framework::signer;
    use std::string::{utf8, String};
    use aptos_std::table::{Self, Table};

    struct Feedback has key {
        fb_id: u64,
        message: String,
    }

    struct FeedbackCounter has key {
        count: u64,
    }

    struct FeedbackBook has key {
        feedbacks: Table<u64, Feedback>,
    }

    struct FeedbackCount has key, store {
        count: u64,
    }
    public entry fun isAdmin(addr:address){
        assert!(addr == @anonymous_feedback, 5);
    }
    
    public entry fun initialize_account(account:&signer, msg:String) {
        let account_address = signer::address_of(account);
        isAdmin(account_address);
        if (!exists<Feedback>(account_address)) {
            let fb = Feedback{
                fb_id:0,
                message: msg,
            };
            move_to(account, fb);
        };
        if (!exists<FeedbackCount>(account_address)) {
            let fb_counter = FeedbackCount{
                count:0
            };
            move_to(account, fb_counter);
        };
    }

    public fun send_feedback(account: &signer, feedback_msg: String) acquires FeedbackCount, Feedback  {
        let account_address = signer::address_of(account);
        assert!(exists<FeedbackCount>(account_address), 0); // Ensure FeedbackCount exists
        let fb_count = borrow_global_mut<FeedbackCount>(account_address);
        let fb_body = borrow_global_mut<Feedback>(account_address);

        fb_count.count = fb_count.count + 1;

        fb_body.fb_id = fb_count.count;

        fb_body.message = feedback_msg;

        let feedback = Feedback {
            fb_id: fb_count,
            message: feedback_msg,
        };

        let feedback_book = borrow_global_mut<FeedbackBook>(&account_address);
        table::add(&mut feedback_book.feedbacks, fb_count, feedback);

        borrow_global_mut<FeedbackCount>(&account_address).count = fb_count;
    }

    public fun fetch_feedback(account: &signer): String acquires Feedback {
        let account_address = signer::address_of(account);
        assert!(exists<FeedbackBook>(account_address), 0); // Ensure FeedbackBook exists
        let feedback_book = borrow_global<Feedback>(account_address);
        feedback_book.message
        table::borrow(&feedback_book.feedbacks, fb_id)
    }
}
