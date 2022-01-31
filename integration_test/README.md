## Running tests

### The following tests have no requirements
- change_language_test
- voice_memo_test
- recovery_flow_test
- disappearing_messages_test
- enroll_leave_Me_note_test
- copy_recovery_key_test
- recovery_flow_test

### The following tests require Chats to display only one conversation (other than "Me")
- block_contact_test
- contact_info_screen_test
- delete_contact_test
- rename_contact_test
- send_first_message_test

### The following tests require Chats to display only one conversation (other than "Me") + a hardcoded timestamp
- delete_for_everyone_test
- delete_for_me_test
- react_to_message_test

### The following tests require Chats to display only one conversation (other than "Me") + the conversation to have an image and video attachment already shared
- view_attachments_test

### Require a specific message and contact content to exist 
- search_contacts_messages_test
- search_contacts_test

### Require Chats to display a single message request
- request_flow_test.dart
