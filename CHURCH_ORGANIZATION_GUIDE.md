# 🏛️ Church Organization Feature Guide

## Overview

The Ekklesia app now includes a comprehensive church organization system with role-based access control, referral codes, and member approval workflows.

---

## 🎭 Role Hierarchy

### 1. **Super Admin** (Church Creator)
- The person who creates the church automatically becomes the Super Admin
- **Full Control**: Can do everything
- **Permissions**:
  - Create and manage the church
  - Approve/reject new members
  - Assign roles (Admin, Committee, Member)
  - Manage all church settings
  - Cannot be removed or changed

### 2. **Admin** (Pastor/Leaders)
- Assigned by Super Admin
- **High-Level Management**
- **Permissions**:
  - Approve/reject new members
  - Assign Committee and Member roles
  - Manage church content (events, campaigns, announcements)
  - View all church data
  - Cannot assign other Admins (only Super Admin can)

### 3. **Committee** (Ministry Leaders)
- Approved by Super Admin or Admin
- **Limited Management**
- **Permissions**:
  - Create events and campaigns
  - Post announcements
  - View member list
  - Cannot approve new members
  - Cannot assign roles

### 4. **Member** (Regular Church Members)
- Approved by Super Admin or Admin
- **Basic Access**
- **Permissions**:
  - View church information
  - Attend events
  - Make donations
  - Submit prayer requests
  - Cannot manage anything

### 5. **Pending** (Awaiting Approval)
- Users who joined via referral code but not yet approved
- **No Access** until approved
- Waiting for Admin or Super Admin approval

---

## 🚀 How to Create a Church

### Step 1: Access Create Church Screen
1. Open the app and login
2. On the Home tab, tap **"Create Church"**

### Step 2: Fill in Required Information

#### Required Fields (marked with *):
- **Church Name** *
  - Must be unique across all churches
  - Example: "Grace Community Church"

- **Pastor Name** *
  - Name of the church pastor or leader
  - Example: "Rev. John Smith"

- **Church License Number** *
  - Must be 8-20 alphanumeric characters
  - Must be UNIQUE - no two churches can have the same license
  - Example: "ABC12345XYZ"
  - Auto-converted to uppercase

- **Area/Neighborhood** *
  - Location area of the church
  - Example: "Downtown", "West End"

#### Optional Fields:
- Street Address
- City
- State
- Contact Phone
- Contact Email
- Description

### Step 3: Submit
1. Review all information
2. Tap **"Create Church"**
3. System will validate:
   - ✅ Church name is unique
   - ✅ License number is valid format (8-20 alphanumeric)
   - ✅ License number is unique
4. If successful, you'll see a success dialog with your **Referral Code**

### Step 4: Save Your Referral Code
- A unique 6-character code is generated (e.g., "ABC123")
- **This code is VERY IMPORTANT** - share it with members to join your church
- You can copy it by tapping the copy icon
- The code is permanently stored with your church

---

## 👥 How Members Can Join

### Option 1: Using Referral Code (Recommended)

1. Tap **"Join Church"** on the Home screen
2. Enter the 6-character referral code
3. Tap **"Find Church"**
4. Review church details
5. Tap **"Join This Church"**
6. Status: **Pending** (waiting for admin approval)

### Option 2: Search and Find

1. Tap **"Find Church"** on the Home screen
2. Search by church name or area
3. View church details
4. Join the church
5. Status: **Pending**

---

## ✅ Approving Members (For Super Admin & Admin)

### View Pending Members
1. Go to your church management screen
2. Tap **"Pending Members"**
3. See list of users waiting for approval

### Approve a Member
1. Select the pending member
2. Choose their role:
   - **Member** - Regular member (most common)
   - **Committee** - Ministry leader
   - **Admin** - Church admin/pastor (Super Admin only)
3. Tap **"Approve"**
4. Member is notified and gains access

### Reject a Member
1. Select the pending member
2. Tap **"Reject"**
3. User is removed from pending list

---

## 🔐 License Number Requirements

### Format:
- **Length**: 8 to 20 characters
- **Characters**: Only letters (A-Z) and numbers (0-9)
- **Case**: Auto-converted to UPPERCASE
- **Uniqueness**: Must be unique across ALL churches

### Valid Examples:
- ✅ `ABC12345XYZ` (11 characters)
- ✅ `CHURCH2024` (11 characters)
- ✅ `12345678` (8 characters)
- ✅ `ABCD1234EFGH5678IJKL` (20 characters)

### Invalid Examples:
- ❌ `ABC123` (too short - less than 8)
- ❌ `ABC-123-XYZ` (contains dashes)
- ❌ `church@2024` (contains special characters)
- ❌ `My Church 123` (contains spaces and lowercase)

---

## 🎫 Referral Code System

### How It Works:
1. When a church is created, a **unique 6-character code** is generated
2. Code format: `[A-Z0-9]{6}` (e.g., "ABC123", "X9Y2Z1")
3. Code is **permanent** and cannot be changed
4. Code is **unique** - no two churches have the same code

### Sharing the Code:
- Super Admin and Admins can share the code with potential members
- Members can share with friends/family
- Code can be shared via:
  - WhatsApp
  - SMS
  - Email
  - Social media
  - Printed materials

### Finding Your Church's Code:
1. Go to Church Settings
2. View "Referral Code" section
3. Copy or share as needed

---

## 📊 Database Structure

### Churches Table
```sql
- id (UUID, primary key)
- name (TEXT, unique, not null)
- pastor_name (TEXT)
- license_number (TEXT, unique, not null)
- referral_code (TEXT, unique, not null)
- area (TEXT, not null)
- address, city, state, country (TEXT, optional)
- phone_number, email (TEXT, optional)
- description (TEXT, optional)
- photo_url (TEXT, optional)
- created_by (UUID, references profiles)
- created_at, updated_at (TIMESTAMP)
```

### Church Members Table
```sql
- id (UUID, primary key)
- church_id (UUID, references churches)
- user_id (UUID, references profiles)
- role (TEXT: 'super_admin', 'admin', 'committee', 'member', 'pending')
- approved_by (UUID, references profiles)
- approved_at (TIMESTAMP)
- joined_at (TIMESTAMP)
- UNIQUE constraint on (church_id, user_id)
```

---

## 🎬 Complete Workflow Example

### Scenario: Creating and Managing "Hope Church"

#### Part 1: Church Creation
1. **Pastor John** creates the church:
   - Name: "Hope Fellowship Church"
   - Pastor: "Rev. John Doe"
   - License: "HOPE2024CHURCH"
   - Area: "Downtown"
2. System generates code: **"H7P3E2"**
3. Pastor John is automatically **Super Admin**

#### Part 2: Members Joining
4. **Sarah** receives code "H7P3E2" from Pastor John
5. Sarah enters code in app → Finds "Hope Fellowship Church"
6. Sarah joins → Status: **Pending**
7. **Mike** also joins → Status: **Pending**

#### Part 3: Approving Members
8. Pastor John opens "Pending Members"
9. Approves Sarah as **Admin** (co-pastor)
10. Approves Mike as **Member**
11. Both Sarah and Mike get notifications

#### Part 4: Role Delegation
12. Sarah (now Admin) can also approve new members
13. **Lisa** joins using code
14. Sarah approves Lisa as **Committee** (youth leader)
15. Lisa can now create youth events

---

## 🔒 Security Features

1. **Unique Church Names**: No duplicate church names allowed
2. **Unique License Numbers**: Each church must have unique license
3. **Unique Referral Codes**: Auto-generated, guaranteed unique
4. **Role-Based Access**: Users can only perform actions their role allows
5. **Approval System**: New members must be approved before full access
6. **Audit Trail**: All approvals tracked (who approved, when)

---

## 📱 User Interface

### Home Screen Quick Actions:
- 🏛️ **Create Church** (Green) - For those starting a new church
- 👥 **Join Church** (Blue) - For those joining an existing church
- 🔍 **Find Church** - Browse and search churches

### Church Detail View Shows:
- Church name and logo
- Pastor name
- Location (Area, City)
- Contact information
- Description
- Referral code (for members to share)
- Member count
- Your role in the church

---

## ❓ FAQs

**Q: Can I create multiple churches?**
A: Yes, one user can be the creator of multiple churches.

**Q: Can I be a member of multiple churches?**
A: Yes, you can join multiple churches with different roles in each.

**Q: What if I lose my referral code?**
A: As Super Admin or Admin, you can view the code anytime in Church Settings.

**Q: Can I change the church license number?**
A: No, license numbers are permanent once set.

**Q: What if my license number is already taken?**
A: You must use a different license number. Each must be unique.

**Q: How do I become an Admin?**
A: Only the Super Admin can assign Admin roles.

**Q: Can a Super Admin be removed?**
A: No, the church creator remains Super Admin permanently.

**Q: What happens to pending members after 30 days?**
A: They remain pending until approved or rejected - no automatic expiration.

---

## 🛠️ For Developers

### Key Files:
- `lib/services/church_service.dart` - Church CRUD and validation
- `lib/screens/church/create_church_screen.dart` - Create church UI
- `lib/screens/church/join_church_screen.dart` - Join church UI
- `lib/models/church_model.dart` - Church data model
- `database_setup.sql` - Database schema

### API Methods:
```dart
// Create church
churchService.createChurch(...)

// Join with code
churchService.joinChurchWithReferralCode(...)

// Approve member
churchService.approveMember(...)

// Get pending members
churchService.getPendingMembers(churchId)

// Check user role
churchService.getUserRoleInChurch(...)
```

---

## ✅ Setup Checklist

Before using this feature, ensure:

- [ ] Database tables created (`churches`, `church_members`)
- [ ] Unique constraints added (name, license_number, referral_code)
- [ ] Role check constraints added
- [ ] Supabase RLS policies configured
- [ ] Routes added to main.dart
- [ ] Navigation working from home screen

---

Need help? Check the main [CREDENTIALS_SETUP.md](CREDENTIALS_SETUP.md) for backend setup!
