# AB LEARNING — Merge Resolution Package

แพ็กเกจนี้สร้างจากไฟล์ตรวจสอบที่อัปโหลดมา ไม่ได้เชื่อมต่อหรือแก้ไข Repository บนเครื่อง Windows โดยตรง

## แนวทางที่ใช้
- เก็บ Hi-Fi screens ในไฟล์ `hifi_*` และใช้ legacy implementations ในชื่อเดิมสำหรับหน้าจอที่ Router จัดไว้ใน `/classic/...`
- ใช้ `AuthRepository` และ `RegisterController` เวอร์ชัน working tree ที่ไม่มี conflict markers
- รวม `.gitignore` และ `analysis_options.yaml`
- ใช้ Stage 3 tests และ lockfile; หลังนำไปใช้ต้องรัน `flutter pub get`, `flutter analyze`, `flutter test`
- เพิ่ม route compatibility สำหรับ `/ai-tutor`, `/certificate/:courseName`, `/skill-assessment`, `/career-path`, `/live`, `/jobs`
- ปรับ role guard ไม่ให้ redirect `/classic/login` และ `/classic/register` เหมือนหน้าที่ต้องล็อกอิน

## วิธีใช้
1. แตก ZIP นี้ไปยังโฟลเดอร์ชั่วคราว
2. เปิด PowerShell ในโฟลเดอร์แพ็กเกจ
3. รัน `./Apply-ABLearning-MergeResolution.ps1 -RepoPath 'D:\Project\Ablearnningonline'`
4. ตรวจไฟล์และสำรองข้อมูลที่สคริปต์สร้างไว้ จากนั้นรันคำสั่งตรวจสอบตามที่สคริปต์แสดง
5. **อย่าเพิ่ง stage หรือ continue merge จนกว่า `flutter analyze` และ `flutter test` จะผ่าน**

หมายเหตุ: เนื่องจากไฟล์ที่ส่งมาเป็น audit bundle ของ 18 conflict files ไม่ใช่สำเนา repository ทั้งหมด จึงยังไม่สามารถยืนยันผลคอมไพล์/ทดสอบจริงจากที่นี่ได้ การนำแพ็กเกจไปใช้ต้องตามด้วย validation บนเครื่องที่มีโปรเจกต์เต็ม
