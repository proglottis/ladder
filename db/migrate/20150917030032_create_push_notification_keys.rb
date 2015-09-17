class CreatePushNotificationKeys < ActiveRecord::Migration
  def change
    create_table :push_notification_keys do |t|
      t.references :user, index: true, null: false
      t.string :gcm

      t.timestamps null: false
    end
  end
end
