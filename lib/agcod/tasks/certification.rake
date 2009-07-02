namespace :AGCOD do
  namespace :certification do
    desc "Runs first round of AGCOD testing"
    task :first_round => :environment do
      puts "=====Running success cases======="
      #run health check
      health_check = AGCOD::HealthCheck.new
      health_check.submit
      raise "1st Health Check Failed" unless health_check.successful?

      first_gift_card_creation = AGCOD::CreateGiftCard.new("request_id" => request_ids[0], "value" => 12.34)
      first_gift_card_creation.submit
      unless first_gift_card_creation.successful?
        raise "1st gift card creation failed #{first_gift_card_creation.errors.join(",")}" 
      end

      second_gift_card_creation = AGCOD::CreateGiftCard.new("request_id" => request_ids[1], "value" => 12.34)
      second_gift_card_creation.submit
      raise "2nd gift card creation failed" unless second_gift_card_creation.successful?

      repeated_request_id = request_ids[2]
      first_repeat_creation = AGCOD::CreateGiftCard.new("request_id" => repeated_request_id, "value" => 12.34)
      first_repeat_creation.submit
      raise "first repeated gift card creation failed" unless first_repeat_creation.successful?

      second_repeat_creation = AGCOD::CreateGiftCard.new("request_id" => repeated_request_id, "value" => 12.34)
      second_repeat_creation.submit
      raise "second repeated gift card creation failed" unless second_repeat_creation.successful?

      if second_repeat_creation.claim_code != first_repeat_creation.claim_code
        raise "first and second repeated gift cards do not have matching claim codes"
      end

      first_recon = AGCOD::ReconcileTransactions.new("reconciliation_batch_id" => "1")
      i = 1
      [first_gift_card_creation, second_gift_card_creation, first_repeat_creation, second_repeat_creation].each do |c|
        first_recon << AGCOD::ReconciliationRecord.new("record_id" => i, 
          "request_id" => c.request_id,
          "response_id" => c.response_id,
          "transaction_amount" => c.value,
          "net_amount" => c.value,
          "transaction_type" => "CreateGiftCard",
          "timestamp" => c.timestamp)

        i += 1
      end

      first_recon.submit
      raise "First reconiciliation attempt failed" unless first_recon.successful?

      fourth_gift_card_creation = AGCOD::CreateGiftCard.new("request_id" => request_ids[3], "value" => 12.34)
      fourth_gift_card_creation.submit
      raise "4th gift card creation failed" unless fourth_gift_card_creation.successful?

      cancel_fourth = AGCOD::CancelGiftCard.new("request_id" => fourth_gift_card_creation.request_id, 
        "value" => fourth_gift_card_creation.value, "response_id" => fourth_gift_card_creation.response_id)
      cancel_fourth.submit
      raise "Cancellation of fourth creation failed" unless cancel_fourth.successful?

      fifth_gift_card_creation = AGCOD::CreateGiftCard.new("request_id" => request_ids[4], "value" => 12.34)
      fifth_gift_card_creation.submit
      raise "5th gift card creation failed" unless fifth_gift_card_creation.successful?

      void_fifth = AGCOD::VoidGiftCardCreation.new("request_id" => fifth_gift_card_creation.request_id,
        "value" => fifth_gift_card_creation.value)
      void_fifth.submit
      raise "Voiding of fifth creation failed" unless void_fifth.successful?

      second_recon = AGCOD::ReconcileTransactions.new("reconciliation_batch_id" => 2)
      i = 1
      [fourth_gift_card_creation, cancel_fourth].each do |t|
        second_recon << AGCOD::ReconciliationRecord.new("record_id" => i,
          "request_id" => t.request_id,
          "response_id" => t.response_id,
          "transaction_amount" => fourth_gift_card_creation.value,
          "net_amount" => fourth_gift_card_creation.value,
          "transaction_type" => AGCOD::ReconciliationRecord.get_type_for(t),
          "timestamp" => t.timestamp
        )
        i += 1
      end

      [fifth_gift_card_creation, void_fifth].each do |t|
          second_recon << AGCOD::ReconciliationRecord.new("record_id" => i,
            "request_id" => t.request_id,
            "response_id" => fifth_gift_card_creation.response_id,
            "transaction_amount" => fifth_gift_card_creation.value,
            "net_amount" => fifth_gift_card_creation.value,
            "transaction_type" => AGCOD::ReconciliationRecord.get_type_for(t),
            "timestamp" => t.timestamp
          )  
        i += 1
      end

      second_recon.submit
      raise "Second reconciliation failed" unless second_recon.successful?


      puts "====SUCCESS CASES SUCCESSFUL==="

      puts describe_gift_card_creation(first_gift_card_creation, "Request 1")
      puts describe_gift_card_creation(second_gift_card_creation, "Request 2")
      puts describe_gift_card_creation(first_repeat_creation, "Request 3")

      puts describe_reconciliation(first_recon, "Reconciliation 1")

      puts describe_gift_card_creation(fourth_gift_card_creation, "Request 4")
      puts describe_gift_card_creation(fifth_gift_card_creation, "Request 5")

      puts describe_reconciliation(second_recon, "Reconciliation 2")

      #ouput first, second, and third case for later use
      `rm -rf AGCOD_results.yml`
      result_file = File.open("AGCOD_results.yml", "w")
      result_file.puts [
        first_gift_card_creation,
        second_gift_card_creation,
        first_repeat_creation,
        fourth_gift_card_creation,
        fifth_gift_card_creation
      ].to_yaml
      result_file.close

    end

    desc "second round of AGCOD certification testing"
    task :second_round => :environment do
      puts "=====Running first set of failure cases======="
      persisted_responses = load_saved_requests
      first_cancel = AGCOD::CancelGiftCard.new("request_id" => persisted_responses[0]["request_id"], 
        "value" => persisted_responses[0]["value"], "response_id" => persisted_responses[0]["response_id"])
      first_cancel.submit

      second_cancel = AGCOD::CancelGiftCard.new("request_id" => "674856730", 
        "value" => 12.34, "response_id" => "AAAEPY26ZX1BSY")
      second_cancel.submit

      third_cancel = AGCOD::CancelGiftCard.new("request_id" => "425345236", 
        "value" => 12.34, "response_id" => "A3REPY26ZX1BSY")
      third_cancel.submit

      first_gift_card_request = AGCOD::CreateGiftCard.new("request_id" => "452345287",
        "value" => 12.34, "currency_code" => "")
      first_gift_card_request.submit

      second_gift_card_request = AGCOD::CreateGiftCard.new("request_id" => "45423583487",
        "value" => 100000)
      second_gift_card_request.submit

      puts "===COMPLETE==="
      puts describe_request(first_cancel, "First Cancellation")
      puts describe_request(second_cancel, "Second Cancellation")
      puts describe_request(third_cancel, "Third Cancellation")

      puts describe_gift_card_creation(first_gift_card_request, "Request 6")
      puts describe_gift_card_creation(second_gift_card_request, "Request 7")
    end

    desc "third round of AGCOD certification testing"
    task :third_round => :environment do
      puts "===Running second set of failure cases=="
      first_gift_card_request = do_eighth_request

      second_attrs = load_saved_requests[1]
      cancel = AGCOD::CancelGiftCard.new("request_id" => second_attrs["request_id"], 
        "response_id" => second_attrs["response_id"])
      cancel.submit

      puts "===COMPLETE==="
      puts describe_gift_card_creation(first_gift_card_request)
      puts describe_request(cancel)
    end

    desc "fourth round of AGCOD certification testing"
    task :fourth_round => :environment do
      puts "===Running third set of failure cases==="

      #todo wrap a rescue block
      first_gift_card_request = AGCOD::CreateGiftCard.new("request_id" => "5342856786", "value" => 12.34)
      first_gift_card_request.submit

      void_gift_card = AGCOD::VoidGiftCardCreation.new("request_id" => first_gift_card_request.request_id)
      void_gift_card.submit

      puts void_gift_card.response

      requests = load_saved_requests
      cancel_gift_card = AGCOD::CancelGiftCard.new("request_id" => requests[1]["request_id"], 
        "response_id" => requests[1]["response_id"])
      cancel_gift_card.submit

      recon = AGCOD::ReconcileTransactions.new("reconciliation_batch_id" => 3)
      i = 1
      ["CreateGiftCard", "CancelGiftCard"].each do |t|
        recon << AGCOD::ReconciliationRecord.new("record_id" => i,
          "request_id" => requests[3]["request_id"],
          "response_id" => requests[3]["response_id"],
          "transaction_amount" => requests[3]["value"],
          "net_amount" => requests[3]["value"],
          "transaction_type" => t,
          "timestamp" => requests[3]["timestamp"]
        )
        i += 1
      end

      ["CreateGiftCard", "CancelGiftCard"].each do |t|
          recon << AGCOD::ReconciliationRecord.new("record_id" => i,
            "request_id" => requests[4]["request_id"],
            "response_id" => requests[4]["response_id"],
            "transaction_amount" => requests[4]["value"],
            "net_amount" => requests[4]["value"],
            "transaction_type" => t,
            "timestamp" => requests[4]["timestamp"]
          )
        i += 1
      end

      recon.submit

      puts "Complete"
      {"creation" => first_gift_card_request, "void" => void_gift_card, "cancel" => cancel_gift_card, 
        "recon" => recon}.each do |key, value|
        puts describe_request(value, key)
      end
    end

    desc "fifth round of AGCOD Certification testing"
    task :fifth_round => :environment do
      puts "===Starting 5th round==="
      request = do_eighth_request

      raise "Request failed" unless request.successful?

      puts "Complete"
      puts describe_gift_card_creation(request)

    end

    desc "sixth round of AGCOD Certification test"
    task :sixth_round => :environment do
      puts "===Starting 6th round==="
      first_recon = AGCOD::ReconcileTransactions.new("reconciliation_batch_id" => 45)
      second_recon = AGCOD::ReconcileTransactions.new("reconciliation_batch_id" => 46)
      request_id = 1510
      record_id = 34
      creation_requests = []
      12.times do 
        request = AGCOD::CreateGiftCard.new("request_id" => request_id, "value" => 12.34)
        request.submit

        creation_requests << request

        raise "creation request #{request_id} failed" unless request.successful?

        first_recon << AGCOD::ReconciliationRecord.new("record_id" => record_id,
          "request_id" => request.request_id,
          "response_id" => request.response_id,
          "transaction_amount" => request.value,
          "net_amount" => request.value,
          "transaction_type" => AGCOD::ReconciliationRecord.get_type_for(request),
          "timestamp" => request.timestamp
        )
        request_id += 1
        record_id += 1
      end

      i = 0
      5.times do
        cancellation = AGCOD::CancelGiftCard.new("request_id" => creation_requests[i].request_id,
          "response_id" => creation_requests[i].response_id)
        cancellation.submit

        raise "cancellation request failed for #{creation_requests[i].request_id}" unless cancellation.successful?

        second_recon << AGCOD::ReconciliationRecord.new("record_id" => record_id,
          "request_id" => creation_requests[i].request_id,
          "response_id" => creation_requests[i].response_id,
          "transaction_amount" => creation_requests[i].value,
          "net_amount" => creation_requests[i].value,
          "transaction_type" => "CancelGiftCard",
          "timestamp" => creation_requests[i].timestamp)
        i += 1
        record_id += 1
      end

      5.times do
        void = AGCOD::VoidGiftCardCreation.new("request_id" => creation_requests[i].request_id)
        void.submit

        raise "cancellation request failed for #{creation_requests[i].request_id}" unless void.successful?

        second_recon << AGCOD::ReconciliationRecord.new("record_id" => record_id,
          "request_id" => creation_requests[i].request_id,
          "response_id" => creation_requests[i].response_id,
          "transaction_amount" => creation_requests[i].value,
          "net_amount" => creation_requests[i].value,
          "transaction_type" => "VoidGiftCard",
          "timestamp" => creation_requests[i].timestamp)

        i += 1
        record_id += 1
      end

      first_recon.submit
      raise "first reconciliation failed" unless first_recon.successful?

      second_recon.submit
      raise "second reconciliation failed" unless second_recon.successful?

      j = 1
      creation_requests.each do |r|
        puts describe_gift_card_creation(r, "GiftCard #{j}") 
        j += 1
      end

      k = 1
      [first_recon, second_recon].each do |r|
        puts describe_reconciliation(r, "Reconciliation #{k}")
        k += 1
      end
    end

    desc "7th round of certification testing"
    task :seventh_round => :environment do
      ninth_request = AGCOD::CreateGiftCard.new("request_id" => request_ids[5], "value" => 5000)
      ninth_request.submit
      unless ninth_request.successful?
        raise "9th gift card creation failed #{ninth_request.errors.join(",")}" 
      end

      recon = AGCOD::ReconcileTransactions.new("reconciliation_batch_id" => 6129)
      recon << AGCOD::ReconciliationRecord.new("record_id" => 1,
        "request_id" => ninth_request.request_id,
        "response_id" => ninth_request.response_id,
        "transaction_amount" => ninth_request.value,
        "transaction_type" => "CreateGiftCard",
        "timestamp" => ninth_request.timestamp)
      recon.submit
      puts recon.request
      puts recon.response
      raise "Reconciliation Failed for \#9" unless recon.successful?

      puts describe_gift_card_creation(ninth_request, "GiftCard \#9") 
      puts describe_reconciliation(recon, "Reconciliation for \#9")
    end

    def request_ids
      [
        "314124534",
        "4312334242",
        "545326",
        "3467456",
        "653467",
        "4368436315443"
      ]
    end

    def do_eighth_request
      request = AGCOD::CreateGiftCard.new("request_id" => "454235834879",
        "value" => 12.34)
      request.submit

      request
    end
    def describe_gift_card_creation(c, header = "Creation")
      "==#{header}==\nRequest ID: #{::AGCOD_ENV["partner_id"]}#{c.request_id}\nResponse ID: #{c.response_id}\n" + 
      "Claim Code: #{c.claim_code}\nTime: #{c.timestamp}"
    end

    def describe_request(c, header = "Cancellation")
      "==#{header}==\nRequest ID: #{::AGCOD_ENV["partner_id"]}#{c.request_id}\nTimestamp: #{c.timestamp}"
    end

    def describe_reconciliation(r, header = "Reconciliation")
      "==#{header}==\nTime: #{r.timestamp}\nPartner:#{::AGCOD_ENV["partner_id"]}\nBatch ID: #{::AGCOD_ENV["partner_id"] }#{r.reconciliation_batch_id}"
    end

    def load_saved_requests

      results = File.read("AGCOD_results.yml")

      YAML.load(results) || {}
    end
  end
end