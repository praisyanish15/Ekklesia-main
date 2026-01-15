# 🚀 Onboarding Flow Guide
## Ekklesia - Church Beyond Sunday

> _"Welcome to your church family."_

---

## ✨ Philosophy

**Goal**: Get churches and members connected in under 3 minutes.

**Principles**:
- 🎯 **Minimal**: Only ask what's absolutely necessary
- 💙 **Warm**: Make people feel welcome, not interrogated
- ⚡ **Fast**: Respect people's time
- 🧠 **Smart**: Auto-configure based on church needs

---

## 📱 Complete User Flow

### 🟢 SCREEN 1: Welcome / Entry

**Purpose**: Identify user type without asking directly

**Design**:
- Clean gradient background (blue)
- Church icon in circle
- App name: "Ekklesia"
- Tagline: "Church beyond Sunday."
- Welcome message: "Welcome to your church family."

**Actions**:
```
[Join My Church]     ← Primary CTA (filled button, white)
[I'm a Pastor / Leader]  ← Secondary CTA (outlined button)
```

**User Paths**:
- Member → Screen 2B (Member Join)
- Pastor → Screen 2A (Pastor Setup)

**File**: [welcome_screen.dart](lib/screens/onboarding/welcome_screen.dart)

---

### 🟢 SCREEN 2A: Pastor Setup (First Time)

**Purpose**: Create church in 2 minutes

**Progress**: Step 1 of 2

**Fields**:
```
Church Name *          [Grace Community Church]
City *                 [Mumbai]
Pastor / Admin Name *  [Pastor John]
License Number *       [CH12345678]
WhatsApp Number *      [+91 98765 43210]
```

**Validation**:
- Church name: Check uniqueness
- License number: 8-20 alphanumeric, check uniqueness
- WhatsApp: Valid phone format

**Auto-Assigned**:
- Referral code (6-char, unique, auto-generated)
- Creator becomes Super Admin automatically
- Church status: Active

**CTA**: `Set Up My Church`

**Next**: Screen 3 (Church Focus Selection)

**File**: [pastor_setup_screen.dart](lib/screens/onboarding/pastor_setup_screen.dart)

---

### 🟢 SCREEN 2B: Member Join

**Purpose**: Join existing church

**Fields**:
```
Church Code *          [ABC123] (6 digits)
                       [QR Scan Button]

--- Optional ---
Full Name              [Your name]
Phone Number           [+91 98765 43210]
```

**Features**:
- QR code scanner icon (for scanning church display)
- Info card: "Where do I find the church code?"
  - Ask pastor/admin
  - Check announcements
  - Scan QR at church

**Approval Flow**:
- Member submits request
- Status: Pending
- Admin gets notification
- Admin approves → Member becomes active

**CTA**: `Join My Church`

**Next**: Home (with pending approval notice if needed)

**File**: [member_join_screen.dart](lib/screens/onboarding/member_join_screen.dart)

---

### 🟢 SCREEN 3: Choose Church Focus (Pastors Only)

**Purpose**: Auto-configure app based on church priority

**Progress**: Step 2 of 2

**Question**: "What does your church need most right now?"

**Options** (select 1):

#### 🙏 Prayer (Purple)
**Description**: Build a culture of prayer and intercession
**Features**:
- Prayer Wall
- Prayer Requests
- Answered Prayers

#### 🌱 New Believers (Green)
**Description**: Disciple and nurture new Christians
**Features**:
- New Believer Path
- Baptism Track
- Mentorship

#### 👥 Member Care (Blue)
**Description**: Connect and care for your congregation
**Features**:
- Check-ins
- Care Groups
- Follow-ups

#### 🔥 Youth (Orange)
**Description**: Engage and grow the next generation
**Features**:
- Youth Path
- Events
- Mentorship

**Note**: "Choose one focus to get started. You can add more features anytime."

**Auto-Configuration**:
Based on selection:
- Prayer → Enable Prayer Wall, set default discipleship path
- New Believers → Enable New Believer Path, setup baptism tracking
- Member Care → Enable check-in features, care group tools
- Youth → Enable Youth Path, event management

**CTA**: `Complete Setup`

**Next**: Home Dashboard (fully configured)

**File**: [church_focus_screen.dart](lib/screens/onboarding/church_focus_screen.dart)

---

## 🏠 Post-Onboarding Experience

### First Login Experience

#### For Pastors (After Setup):
1. Welcome message: "Church setup complete! Welcome to Ekklesia."
2. Home dashboard shows:
   - Church referral code card (share with members)
   - Quick action: Invite members
   - Quick action: Submit first prayer/content based on focus
3. Gentle tutorial (skippable): "Your church can now [prayer/grow/connect]"

#### For Members (After Join):
1. Pending approval state:
   - "Your request has been sent to [Church Name]"
   - "You'll be notified when approved"
   - Limited access: Can browse, can't interact yet

2. After approval:
   - "Welcome to [Church Name] family!"
   - Home dashboard unlocked
   - Gentle tutorial (skippable): How to pray, grow, connect

---

## 🎨 UI/UX Principles

### Visual Design
- **Clean**: Lots of white space
- **Warm**: Soft blues, encouraging copy
- **Simple**: One action per screen
- **Progress**: Show steps (1 of 2, 2 of 2)

### Copy Tone
- **Pastoral**: "Welcome to your church family" (not "Sign up")
- **Encouraging**: "Connect with your church family" (not "Enter details")
- **Respectful**: "Takes just 2 minutes" (acknowledge their time)
- **Safe**: "Your request will be reviewed" (build trust)

### Error Handling
- **Friendly**: "Hmm, that code doesn't match any church" (not "Invalid code")
- **Helpful**: "Church code must be 6 characters" (specific)
- **Graceful**: "Already a member? Try logging in instead"

---

## 🗄️ Database Changes

### churches Table (Add Column)
```sql
ALTER TABLE churches ADD COLUMN primary_focus TEXT CHECK (primary_focus IN ('prayer', 'newBelievers', 'memberCare', 'youth'));
```

### church_members Table (Approval Flow)
```sql
-- role can be: 'pending', 'member', 'committee', 'admin', 'super_admin'
-- When joining: role = 'pending'
-- After approval: role = 'member' (or higher)
```

---

## 🔐 Security & Privacy

### Pastor Setup
- ✅ License number must be unique (prevents duplicate churches)
- ✅ Church name must be unique (prevents confusion)
- ✅ Creator auto-becomes super_admin (owns the church)
- ✅ Referral code auto-generated (6-char, unique)

### Member Join
- ✅ Referral code validation (must exist)
- ✅ Duplicate check (can't join same church twice)
- ✅ Approval required (pending → member)
- ✅ RLS policies enforce church boundaries

---

## 📊 Success Metrics

### Onboarding Completion Rate
- **Pastor**: % who complete both steps
- **Member**: % who successfully join a church

### Time to Complete
- **Pastor**: Target <3 minutes
- **Member**: Target <1 minute

### Drop-off Points
- Track where users abandon flow
- Optimize those screens

---

## 🎯 User Journey Examples

### Example 1: Pastor John Sets Up Church

**Sunday Morning**:
1. Downloads Ekklesia
2. Opens app → Welcome Screen
3. Taps "I'm a Pastor / Leader"
4. Fills in church details (2 min)
   - Grace Community Church
   - Mumbai
   - Pastor John
   - CH87654321
   - +91 98765 43210
5. Selects "Prayer" as focus
6. Setup complete!
7. Gets referral code: ABC123
8. Shows QR code on Sunday screen

**Sunday Afternoon**:
- 15 members scan QR code
- All go to "pending" status
- John approves all 15 in one tap
- Church is live!

**Monday**:
- First prayer request submitted
- Prayer Wall active
- Church beyond Sunday begins

---

### Example 2: Sarah Joins Church

**Sunday Service**:
1. Sees QR code on screen
2. Scans with app
3. Code auto-fills: ABC123
4. Optionally adds name
5. Taps "Join My Church"
6. Sees: "Request sent! Your church admin will approve you soon."

**Monday Morning**:
- Gets notification: "You're now a member of Grace Community Church!"
- Opens app
- Sees home dashboard
- Taps Prayer Wall
- Submits first prayer request
- Feels connected

---

## 🚨 Edge Cases & Solutions

### Problem: User has no church code
**Solution**:
- Info card explains where to get it
- Option to contact support
- "Don't have a code? Ask your pastor"

### Problem: Invalid church code
**Solution**:
- Friendly error: "Hmm, that code doesn't match any church"
- Suggest: "Double-check the code or ask your pastor"

### Problem: User already joined this church
**Solution**:
- "You're already a member of this church!"
- Button: "Go to Home"

### Problem: Church name already taken
**Solution**:
- "A church with this name already exists"
- Suggest: "Try adding your city: Grace Church Mumbai"

### Problem: License number already used
**Solution**:
- "This license number is already registered"
- "Contact support if this is an error"

### Problem: Pastor wants to add co-admin during setup
**Solution**:
- Not during onboarding (too complex)
- After setup, go to Settings → Team → Invite Admin

---

## 🎨 Visual Flow Diagram

```
┌─────────────────┐
│  Welcome Screen │
│   (Screen 1)    │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌───────┐  ┌──────────┐
│Member │  │  Pastor  │
│ Join  │  │  Setup   │
│(2B)   │  │  (2A)    │
└───┬───┘  └────┬─────┘
    │           │
    │           ▼
    │      ┌─────────┐
    │      │ Church  │
    │      │ Focus   │
    │      │  (3)    │
    │      └────┬────┘
    │           │
    └─────┬─────┘
          ▼
    ┌──────────┐
    │   Home   │
    │Dashboard │
    └──────────┘
```

---

## 📋 Implementation Checklist

### Screens Created
- [x] Welcome/Entry Screen
- [x] Pastor Setup Screen
- [x] Church Focus Selection Screen
- [x] Member Join Screen

### Backend
- [x] Church creation flow
- [x] Referral code generation
- [x] Member approval system
- [ ] Add `primary_focus` column to churches table

### Features
- [x] License number validation
- [x] Church name uniqueness check
- [x] Referral code validation
- [x] Duplicate member check
- [ ] QR code scanning (TODO)
- [ ] Auto-configuration based on focus

### Navigation
- [ ] Add welcome screen as app entry point
- [ ] Route to appropriate screen based on user state
- [ ] Handle pending approval state
- [ ] Navigate to home after onboarding

---

## 🔗 Related Documentation

- [Prayer Wall Guide](PRAYER_WALL_GUIDE.md) - First feature based on "Prayer" focus
- [Testimony Vault Guide](TESTIMONY_VAULT_GUIDE.md) - Faith-building feature
- Database Schema - Church and member tables

---

## 💡 Future Enhancements

### V2 Features
- [ ] QR code scanning for member join
- [ ] Bulk member approval
- [ ] Church search (browse churches near me)
- [ ] Multi-church membership
- [ ] Transfer member between churches
- [ ] Church deactivation/archival

### Admin Features
- [ ] Customize welcome message for new members
- [ ] Set approval requirements (auto vs manual)
- [ ] Member onboarding checklist
- [ ] New member orientation path

---

**Remember**: Onboarding is the first impression. Make it warm, simple, and pastoral - not corporate or complicated.

_"And let us consider how we may spur one another on toward love and good deeds, not giving up meeting together, as some are in the habit of doing, but encouraging one another."_ - Hebrews 10:24-25
