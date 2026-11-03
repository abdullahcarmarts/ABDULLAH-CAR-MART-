ABDULLAH CAR MART — ONLINE MANAGEMENT SYSTEM

SECURE QR MODE
Public QR verification displays vehicle make/model/year, status, registration, color, mileage, sale/demand price, transaction type/date and car photos. It does NOT display buyer/seller names, CNIC, phone, addresses, personal photos, purchase price, advance, notes, chassis/engine numbers or chassis photo. Those remain admin-only.

SETUP
1. In Supabase Dashboard, open your project.
2. Open SQL Editor → New query.
3. Open schema.sql from this package, copy all its contents, paste into SQL Editor, and press Run.
4. Supabase Dashboard → Authentication → Users → Add user. Create your admin email/password. Keep the password private.
5. Open Project Settings → API. Copy the Project URL and the anon/public (publishable) key. Do NOT use or share the service_role/secret key.
6. Open index.html after hosting it on an HTTPS website. Enter Project URL and anon/public key, then Connect.
7. Log in using the admin user you created.

HOSTING
Host this folder on Vercel or another static HTTPS host. QR verification works only after hosting; a local file QR link will not work for other people.

IMPORTANT
This is a starter system, not a production-audited accounting or legal records platform. The storage bucket serves images by URL; the public QR page only publishes car photo URLs. Avoid uploading sensitive identity documents or signatures. Never share your Supabase password or service_role key.
