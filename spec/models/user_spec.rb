require 'rails_helper'

describe User do

  it "has a valid factory" do
    expect(Fabricate.build(:user)).to be_valid
  end

  describe ".student?" do
    [:alum, :professor, :staff].each do |non_student_type|
      context "when explict #{non_student_type}" do
        let(:non_student) { Fabricate.build(non_student_type) }

        it "returns false" do
          expect(non_student.student?).to be_falsy
        end
      end
    end

    context "when student type" do
      context "who has graduated" do
        let(:student) { Fabricate.build(:student, class_year: Student.senior_year - 1) }

        it "returns false" do
          expect(student.student?).to be_falsy
        end
      end

      context "who has not graduated" do
        let(:student) { Fabricate.build(:student, class_year: Student.senior_year) }

        it "returns true" do
          expect(student.student?).to be_truthy
        end
      end
    end
  end

  let(:user) { Fabricate.build(:user, unix_id: "sl14") }
  
  context ".email" do
    it "returns personal information" do
      expect(user.email).to eq("sl14@williams.edu")
    end
  end

  context ".name_string" do    
    let(:student) { Fabricate.build(:student, class_year: Student.senior_year) }

    context "when student" do
      it "returns user's name + 'class_year abbreviation" do
        abbrev = Student.senior_year % 100
        expect(student.name_string).to eq("#{student.name} '#{abbrev}")
      end
    end

    context "when not student" do
      let(:non_student) { Fabricate(:user) }
      it "only returns the user's name" do
        expect(non_student.name_string).to eq(non_student.name)
      end
    end
  end

  context ".with_access_token" do
    it "returns nil if the access_token is invalid/doesn't exist" do
      expect(User.with_access_token(12345)).to be_nil
    end
  end

  context "empty fields" do
    let(:user) { Fabricate.build(:user, unix_id: "sl14") }
    
    it "uses the unix if the email is empty" do
      user.update(williams_email: '')
      expect(user.email).to eq("sl14@williams.edu")
    end
  end

  # Presence validations
  [:unix_id, :williams_email, :name].each do |attr|
    it "validates presence of #{attr}" do
      expect(Fabricate.build(:user, attr => nil)).not_to be_valid
    end
  end

  it "requires unix id" do
    expect(Fabricate.build(:user, unix_id: nil)).not_to be_valid
  end

  it "validates uniqueness of unix_id" do
    Fabricate(:user, unix_id: "ml10")
    expect(Fabricate.build(:user, unix_id: "ml10")).not_to be_valid
  end

  context ".home_address" do
    context "when home_visible is false" do
      let(:user) { Fabricate(:user, home_visible: false) }

      it "returns nil" do
        expect(user.home_address).to be_nil
      end
    end

    context "when from United States" do
      let(:american) { Fabricate.build(:user, home_visible: true, home_country: "United States") }
      
      it "excludes the country" do
        expect(american.home_address).not_to include("United States")
      end
    end

    context "when from outside the United States" do
      let(:commie) { Fabricate.build(:user, home_visible: true, home_country: "France") }

      it "includes the country" do
        expect(commie.home_address).to include("France")
      end
    end

    # it might be worth doing this for other parts as well, but state is most likely
    # and if it fails/works, the others likely would fail/work
    context "when state is missing" do
      let(:user) { Fabricate.build(:user, 
        home_visible: true, 
        home_state: nil, 
        home_country: "Switzerland", 
        home_town: "Zurich") 
      }

      it "displays as city, country" do
        expect(user.home_address).to eq("Zurich, Switzerland")
      end
    end
  end

  context "#ldap_lookup" do
    let(:ldap) { DirectoryTools::Ldap.new }
    let(:attrs) { {
      "uid" => "ml10",
      "cn" => "Matthew LaRose",
      "mail" => "matthew.larose@williams.edu",
      "wmsClass" => "16"
      } }

    context "when valid unix" do
      context "and user visible" do
        before(:each) do
          allow_any_instance_of(DirectoryTools::Ldap).to receive(:each_user).
          with("uid", "ml10").
          and_yield(attrs)
        end
      end

      context "and listed dorm in ldap does not exist in our db" do
        let(:peach_castle) { Fabricate(:dorm, name: "Princess Peach's Castle") }
        let(:attrs) do 
        {
          "visible" => true,
          "uid" => "ml10",
          "cn" => "Matthew LaRose",
          "mail" => "matthew.larose@williams.edu",
          "wmsClass" => "16",
          "wmsDormAddr1" => "Hyrule Castle"
        }
        end

        before(:each) do
          allow_any_instance_of(DirectoryTools::Ldap).to receive(:each_user).
          with("uid", "ml10").
          and_yield(attrs)
        end        

        subject(:user) { User.ldap_lookup("ml10").first }

        it "gives user null dorm room" do
          expect(user[:dorm_room]).to be_nil
        end

        it "does not create the dorm" do
          expect(Dorm.where(name: "Hyrule Castle").first).to be_nil
        end

        it "logs a warning" do
          expect(Rails.logger).to receive(:warn).
          with("Encountered unknown dorm: Hyrule Castle")
          User.ldap_lookup("ml10")
        end
      end

      context "and listed dorm in ldap does not exist in our db" do
        let!(:peach_castle) { Fabricate(:dorm, name: "Princess Peach's Castle") }
        let(:attrs) do 
        {
          "visible" => true,
          "uid" => "ml10",
          "cn" => "Matthew LaRose",
          "mail" => "matthew.larose@williams.edu",
          "wmsClass" => "16",
          "wmsDormAddr1" => "Princess Peach's Castle"
        }
        end

        before(:each) do
          allow_any_instance_of(DirectoryTools::Ldap).to receive(:each_user).
          with("uid", "ml10").
          and_yield(attrs)
        end        

        subject(:user) { User.ldap_lookup("ml10").first }

        it "gives user null dorm room" do
          expect(user[:dorm_room].dorm).to eq(peach_castle)
        end
      end

      context "and listed dorm is nil" do
        let(:attrs) do 
        {
          "visible" => true,
          "uid" => "ml10",
          "cn" => "Matthew LaRose",
          "mail" => "matthew.larose@williams.edu",
          "wmsClass" => "16",
          "wmsDormAddr1" => nil
        }
        end

        before(:each) do
          allow_any_instance_of(DirectoryTools::Ldap).to receive(:each_user).
          with("uid", "ml10").
          and_yield(attrs)
        end        

        subject(:user) { User.ldap_lookup("ml10").first }

        it "gives user null dorm room" do
          expect(user[:dorm_room]).to be_nil
        end        
      end

      context "and user NOT visible" do
        before(:each) do
          allow_any_instance_of(DirectoryTools::Ldap).to receive(:each_user).
          with("uid", "ml10").
          and_yield(attrs.merge(:visible => false))
        end

        subject(:hash) { User.ldap_lookup("ml10") }

        it "excludes home country" do
          expect(hash[:home_country]).to be_nil
        end

        it "excludes home state" do
          expect(hash[:home_state]).to be_nil
        end

        it "excludes home town" do
          expect(hash[:home_town]).to be_nil
        end

        it "excludes home zip" do
          expect(hash[:home_zip]).to be_nil
        end

        it "excludes cell phone" do
          expect(hash[:cell_phone]).to be_nil
        end

        it "excludes title" do
          expect(hash[:title]).to be_nil
        end

        it "excludes campus phone ext" do
          expect(hash[:campus_phone_ext]).to be_nil
        end

        it "excludes room" do
          expect(hash[:room]).to be_nil
        end

        it "excludes su box" do
          expect(hash[:su_box]).to be_nil
        end

        it "excludes major" do
          expect(hash[:major]).to be_nil
        end

        it "excludes department" do
          expect(hash[:department]).to be_nil
        end

        it "sets visible to false" do
          expect(hash[:visible]).to be_falsy
        end
      end
    end
  end

  context "#find_or_create_from_unix_id" do
    context "user already exists" do
      let(:unix_id) { "ml10" }
      let!(:user) { Fabricate(:user, unix_id: unix_id) }

      it "returns the user" do
        expect(User.find_or_create_from_unix_id(unix_id)).to eq(user)
      end
    end

    context "user does not exist" do
      context "unix is valid/current oit unix" do
        context "with valid attrs" do
          let(:attrs) { {
            "uid" => "ml10",
            "cn" => "Matthew LaRose",
            "mail" => "matthew.larose@williams.edu",
            "wmsClass" => "16"
            } }

          before(:each) do
            allow_any_instance_of(DirectoryTools::Ldap).to receive(:each_user).
            with("uid", "ml10").
            and_yield(attrs)

            allow_any_instance_of(LDAP::Conn).to receive(:bind).
            and_return(true)          
          end

          it "creates and returns the user" do
            expect(User.find_or_create_from_unix_id("ml10")).to eq(User.last)
          end
        end

        context "with class year impossible for current student" do
          let(:attrs) { {
            "uid" => "ml10",
            "cn" => "Matthew LaRose",
            "mail" => "matthew.larose@williams.edu",
            "wmsClass" => "99"
            } }

          before(:each) do
            allow_any_instance_of(DirectoryTools::Ldap).to receive(:each_user).
            with("uid", "ml10").
            and_yield(attrs)

            allow_any_instance_of(LDAP::Conn).to receive(:bind).
            and_return(true)          
          end

          it "raises an exception" do
            expect { User.find_or_create_from_unix_id("ml10") }.to raise_error(ActiveRecord::RecordInvalid)
          end            
        end
      end

      context "unix is invalid" do
        before(:each) do
          allow_any_instance_of(LDAP::Conn).to receive(:search2).
          and_return(nil)

          allow_any_instance_of(LDAP::Conn).to receive(:bind).
          and_return(true)          
        end

        it "returns nil" do
          expect(User.find_or_create_from_unix_id("ml10")).to be_nil
        end
      end
    end
  end

  describe "#search" do
    describe "privacy" do
      context "when user matches but not visible" do
        context "by dorm" do
          let!(:dorm) { Fabricate(:dorm, name: "Hyrule Castle") }
          let!(:room) { Fabricate(:dorm_room, dorm: dorm) }
          let!(:student) { Fabricate(:student, dorm_room: room, dorm_visible: false) }

          it "does not show the user" do
            expect(User.search("hyrule castle")).not_to include(student)
          end
        end

        context "by home" do
          let!(:student) { Fabricate(:student, home_country: "hyrule", home_visible: false) }

          it "does not show the user" do
            expect(User.search("hyrule")).not_to include(student)
          end          
        end
      end
    end
  end
end
