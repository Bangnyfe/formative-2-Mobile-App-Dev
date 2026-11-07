// Seeds demo accounts and incident reports for the app demonstration.
//
// Usage (from tools/seed):
//   npm install
//   node seed_demo_data.js <path-to-service-account.json>          # seed
//   node seed_demo_data.js <path-to-service-account.json> --clean  # remove
//
// The Admin SDK bypasses security rules, so this must never run in the app.
// Keep the service account key outside the repository.

const admin = require('firebase-admin');

const keyPath = process.argv[2];
const clean = process.argv.includes('--clean');

if (!keyPath || keyPath.startsWith('--')) {
  console.error('Usage: node seed_demo_data.js <service-account.json> [--clean]');
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.cert(require(keyPath)) });
const auth = admin.auth();
const db = admin.firestore();
const { Timestamp } = admin.firestore;

const PASSWORD = 'demo_pass';

// Plus-addresses of the owner's inbox, so no real student's email is used.
const USERS = {
  amina: { name: 'Amina Hassan', email: 'a.daib+amina@alustudent.com', department: 'Software Engineering' },
  kwame: { name: 'Kwame Mensah', email: 'a.daib+kwame@alustudent.com', department: 'Entrepreneurial Leadership' },
  thandiwe: { name: 'Thandiwe Dlamini', email: 'a.daib+thandiwe@alustudent.com', department: 'International Business and Trade' },
  yusuf: { name: 'Yusuf Abdi', email: 'a.daib+yusuf@alustudent.com', department: 'Software Engineering' },
  staff: { name: 'Grace Uwase', email: 'a.daib+staff@alustudent.com', department: 'Campus Operations', role: 'staff' },
};

const STAFF = 'staff';

// Each report: who filed it, how many days ago, and its status timeline.
// Timeline entries are [status, hoursAfterCreation, note].
const REPORTS = [
  {
    id: 'demo-01', by: 'amina', daysAgo: 6, category: 'facilities',
    title: 'Projector not displaying anything',
    location: 'Learning Commons, Egypt',
    description: 'The projector in Egypt turns on but shows "No signal" with every laptop and HDMI cable we tried. Two classes this week had to share slides on a small TV instead.',
    noticed: ['kwame', 'yusuf', 'thandiwe'],
    timeline: [['inReview', 3, 'IT support notified.'], ['inProgress', 26, 'Replacement HDMI board ordered.']],
  },
  {
    id: 'demo-02', by: 'kwame', daysAgo: 2, category: 'electricity',
    title: 'Several wall sockets not working',
    location: 'Social Commons, Kenya-Burundi',
    description: 'Four of the wall sockets along the window side in Kenya-Burundi have no power. Students cannot charge laptops during long sessions and are crowding around the few working ones.',
    noticed: ['amina', 'thandiwe'],
    timeline: [],
  },
  {
    id: 'demo-03', by: 'thandiwe', daysAgo: 4, category: 'facilities',
    title: 'Speakers crackling during presentations',
    location: 'Enterprise Commons, Algeria',
    description: 'The ceiling speakers in Algeria crackle loudly and cut out whenever the volume goes above half. It is hard to hear videos and guest speakers on calls.',
    noticed: ['yusuf'],
    timeline: [['inReview', 20, 'Audio technician will inspect on Thursday.']],
  },
  {
    id: 'demo-04', by: 'yusuf', daysAgo: 3, category: 'safety',
    title: 'Classroom door lock is broken',
    location: 'Learning Commons, Mozambique',
    description: 'The door to Mozambique no longer locks, so the room stays open overnight. Students sometimes leave laptops and chargers there between sessions, which is a theft risk.',
    noticed: ['amina'],
    timeline: [['inReview', 5, 'Security team informed; locksmith requested.']],
  },
  {
    id: 'demo-05', by: 'amina', daysAgo: 9, category: 'safety',
    title: 'Path lights out near the residence',
    location: 'Student Residence',
    description: 'Most of the lights on the walkway between the Learning Commons and the Student Residence are off. The path is completely dark after 7pm and students walking back late feel unsafe.',
    noticed: ['kwame', 'thandiwe', 'yusuf'],
    timeline: [['inReview', 4, null], ['inProgress', 30, 'Electrician scheduled to replace the bulbs and check the timer.']],
  },
  {
    id: 'demo-06', by: 'kwame', daysAgo: 1, category: 'safety', anonymous: true,
    title: 'Main gate left open and unattended at night',
    location: 'Main Gate',
    description: 'On two nights this week the main gate was left open after 10pm with no guard at the post. People who did not look like students walked in without being checked.',
    noticed: ['thandiwe', 'yusuf'],
    timeline: [],
  },
  {
    id: 'demo-07', by: 'thandiwe', daysAgo: 12, category: 'water',
    title: 'No running water on the second floor',
    location: 'Student Residence',
    description: 'There has been no water in the second floor bathrooms since this morning. Students are carrying buckets from the ground floor to shower.',
    noticed: ['amina', 'yusuf'],
    timeline: [['inReview', 1, null], ['inProgress', 3, 'Plumber on site.'], ['resolved', 20, 'Burst pipe replaced; water restored.']],
  },
  {
    id: 'demo-08', by: 'yusuf', daysAgo: 10, category: 'sanitation',
    title: 'Bins overflowing after lunch',
    location: 'Cafeteria',
    description: 'The bins near the cafeteria exit are overflowing every afternoon and rubbish is spreading onto the floor, attracting flies.',
    noticed: ['kwame'],
    timeline: [['inReview', 6, null], ['resolved', 48, 'Extra bins added and an afternoon collection scheduled.']],
  },
  {
    id: 'demo-09', by: 'amina', daysAgo: 1, category: 'furniture',
    title: 'Broken chairs in the classroom',
    location: 'Enterprise Commons, Cameroon',
    description: 'Three chairs in Cameroon have cracked seats or loose legs. One collapsed during class today; luckily nobody was hurt.',
    noticed: [],
    timeline: [],
  },
  {
    id: 'demo-10', by: 'kwame', daysAgo: 5, category: 'other',
    title: 'Wi-Fi keeps dropping in the library',
    location: 'Library',
    description: 'The campus Wi-Fi disconnects every few minutes in the library, especially near the back study area. It makes online quizzes and research almost impossible.',
    noticed: ['amina', 'thandiwe', 'yusuf'],
    timeline: [['inReview', 8, null], ['inProgress', 50, 'New access point being installed near the study area.']],
  },
  {
    id: 'demo-11', by: 'thandiwe', daysAgo: 7, category: 'sanitation',
    title: 'Leaking tap in the library washroom',
    location: 'Library',
    description: 'The tap in the library washroom will not close properly and the floor is always wet and slippery.',
    noticed: [],
    timeline: [['rejected', 10, 'Duplicate of an earlier report; that one has already been fixed.']],
  },
  {
    id: 'demo-12', by: 'yusuf', daysAgo: 2, category: 'electricity',
    title: 'Exposed wires behind a socket',
    location: 'Social Commons, Guinea',
    description: 'The cover of the socket near the back wall in Guinea has come off and the wires inside are exposed. It is right next to where people sit and plug in.',
    noticed: ['kwame'],
    timeline: [['inReview', 2, 'Marked urgent; area taped off until the electrician arrives.']],
  },
  {
    id: 'demo-13', by: 'amina', daysAgo: 3, category: 'safety', anonymous: true,
    title: 'CCTV camera in the parking area is down',
    location: 'Parking Area',
    description: 'The camera covering the back of the parking area has been hanging loose with no light on for days. Two bikes were reported stolen from that spot last month.',
    noticed: ['thandiwe'],
    timeline: [],
  },
];

async function ensureUser(key, info) {
  let user;
  try {
    user = await auth.getUserByEmail(info.email);
    user = await auth.updateUser(user.uid, {
      password: PASSWORD, displayName: info.name, emailVerified: true,
    });
  } catch (e) {
    if (e.code !== 'auth/user-not-found') throw e;
    user = await auth.createUser({
      email: info.email, password: PASSWORD, displayName: info.name, emailVerified: true,
    });
  }
  await db.collection('users').doc(user.uid).set({
    name: info.name,
    email: info.email,
    role: info.role || 'student',
    department: info.department,
    createdAt: Timestamp.fromDate(daysAgo(14)),
  });
  console.log(`  user  ${info.email} (${info.role || 'student'})`);
  return user.uid;
}

function daysAgo(days) {
  return new Date(Date.now() - days * 24 * 60 * 60 * 1000);
}

function buildReport(report, uids) {
  const createdAt = daysAgo(report.daysAgo);
  const at = (hours) => Timestamp.fromDate(new Date(createdAt.getTime() + hours * 3600 * 1000));

  const history = [
    { status: 'submitted', changedBy: 'Reporter', at: at(0), note: 'Report submitted' },
    ...report.timeline.map(([status, hours, note]) => ({
      status, changedBy: USERS[STAFF].name, at: at(hours), note,
    })),
  ];
  const last = history[history.length - 1];

  return {
    title: report.title,
    description: report.description,
    category: report.category,
    location: report.location,
    status: last.status,
    reporterId: uids[report.by],
    reporterName: USERS[report.by].name,
    isAnonymous: report.anonymous === true,
    photoUrl: null,
    statusHistory: history,
    affectedUserIds: report.noticed.map((key) => uids[key]),
    createdAt: Timestamp.fromDate(createdAt),
    updatedAt: last.at,
  };
}

async function seed() {
  console.log('Creating demo users...');
  const uids = {};
  for (const [key, info] of Object.entries(USERS)) {
    uids[key] = await ensureUser(key, info);
  }

  console.log('Writing demo reports...');
  const batch = db.batch();
  for (const report of REPORTS) {
    // Fixed IDs, so running the script again updates instead of duplicating.
    batch.set(db.collection('incidents').doc(report.id), buildReport(report, uids));
  }
  await batch.commit();
  console.log(`  ${REPORTS.length} reports written`);
  console.log(`\nDone. All demo accounts use the password "${PASSWORD}".`);
}

async function removeDemoData() {
  console.log('Removing demo reports...');
  const batch = db.batch();
  for (const report of REPORTS) {
    batch.delete(db.collection('incidents').doc(report.id));
  }
  await batch.commit();

  console.log('Removing demo users...');
  for (const info of Object.values(USERS)) {
    try {
      const user = await auth.getUserByEmail(info.email);
      await db.collection('users').doc(user.uid).delete();
      await auth.deleteUser(user.uid);
      console.log(`  removed ${info.email}`);
    } catch (e) {
      if (e.code !== 'auth/user-not-found') throw e;
    }
  }
  console.log('Done.');
}

(clean ? removeDemoData() : seed())
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
