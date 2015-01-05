require "spec_helper"

RSpec.describe OrdersController do
  context "Parts" do
    before :each do 
      allow(controller).to receive(:admin_user)
    end

    let(:order) { FactoryGirl.create :order }
    let(:part) { order.parts[0] }
    let(:params) {
      { id: order.id,
        order: {
          part: {
            part.id => { order_group_id: part.order_group_id, quantity: 2, material: "aluminum" }
          }
        }
      }
    }

    describe "manipulate_parts" do
      it "returns http success" do
        get :manipulate_parts, id: order
        expect(response).to be_success
      end
    end

    describe "update_parts" do
      context "valid attributes" do 
        it "updates part attributes" do
          patch :update_parts, params
          updated_part = Part.find part.id
          expect(updated_part.quantity).to eq 2
          expect(updated_part.material).to eq "aluminum"
        end

        it "redirects to the Manipulate parts page" do
          patch :update_parts, params
          expect(response).to redirect_to manipulate_parts_path(order)
        end
      end

      context "invalid attributes" do 
        it "does not update part attributes" do
          # params[:order][:part][4][:material] = ""
          params[:order][:part][part.id][:material] = ""
          patch :update_parts, params
          updated_part = Part.find part.id
          expect(updated_part.quantity).to eq part.quantity
          expect(updated_part.material).to eq part.material
        end

        it "redirects to the Manipulate parts page" do
          patch :update_parts, params
          expect(response).to redirect_to manipulate_parts_path(order)
        end
      end
    end

# expect{ post :create, contact: Factory.attributes_for(:invalid_contact) }.to_not change(Contact,:count)


  end
end
