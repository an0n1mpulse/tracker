# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StudentImagesController, type: :controller do
  context 'as a global administrator' do
    let(:user) { create :global_admin }

    before :each do
      sign_in user
    end

    describe '#index' do
      before :each do
        @student = create :student
        @image1 = create :student_image, student: @student
        @image2 = create :student_image, student: @student

        @student2 = create :student
        @image3 = create :student_image, student: @student2

        get :index, params: { student_id: @student.id }
      end

      it { should route(:get, "/students/#{@student.id}/student_images").to action: :index, student_id: @student.id }
      it { should respond_with 200 }
      it { should render_template :index }

      it 'assigns the current student' do
        expect(assigns(:student)).to eq @student
      end

      it 'student contains its own images' do
        expect(assigns(:student).student_images).to include @image1, @image2
      end

      it 'student does not contain images of other students' do
        expect(assigns(:student).student_images).not_to include @image3
      end

      it 'assigns a new empty image' do
        expect(assigns(:new_image)).to be_instance_of StudentImage
      end
    end

    describe '#create' do
      context 'submits a single image successfully' do
        before :each do
          @student = create :student

          post :create, params: { student_id: @student.id, student_image: { image: [test_image] } }
        end

        it { should route(:post, "students/#{@student.id}/student_images").to action: :create, student_id: @student.id }
        it { should redirect_to student_student_images_url }
        it { should set_flash[:notice].to 'Images uploaded.' }
        it 'saves a new image' do
          expect(StudentImage.where(student_id: @student.id).length).to eq 1
        end

        it 'generates a unique filename for each uploaded image' do
          post :create, params: { student_id: @student.id, student_image: { image: [test_image] } }

          student_images = StudentImage.where(student_id: @student.id)
          expect(student_images[0].image.to_s).not_to eq student_images[1].image.to_s
        end
      end

      context 'submits a single image that fails to save' do
        before :each do
          @student = create :student

          allow_any_instance_of(StudentImage).to receive(:save).and_return false
          post :create, params: { student_id: @student.id, student_image: { image: [test_image] } }
        end

        it { should render_template :index }

        it { should respond_with 500 }
      end

      context 'submits two images' do
        before :each do
          @student = create :student
        end

        context 'both images are valid' do
          before :each do
            post :create, params: { student_id: @student.id, student_image: { image: [test_image, test_image] } }
          end

          it { should redirect_to student_student_images_url }

          it 'saves both images' do
            expect(@student.reload.student_images.length).to eq 2
          end
        end

        context 'one image is invalid' do
          before :each do
            post :create, params: { student_id: @student.id, student_image: { image: [test_image, invalid_image] } }
          end

          it { should respond_with 400 }

          it { should render_template :index }

          it 'does not save any image' do
            expect(@student.reload.student_images.length).to eq 0
          end
        end
      end

      context 'submits an image for nonexisting student' do
        before :each do
          post :create, params: { student_id: 12_345, student_image: { image: [test_image] } }
        end

        it { should render_template :index }

        it { should respond_with 400 }
      end

      context 'submits no image' do
        before :each do
          @student = create :student

          post :create, params: { student_id: @student.id }
        end

        it { should respond_with :bad_request }
        it { should render_template :index }
        it { should set_flash[:alert].to 'No image submitted.' }
      end
    end
  end
end
