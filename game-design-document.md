# Project Angler

## Game Design Document

**Version:** 1.0  
**Status:** Pre-Production  
**Genre:** Fishing / Adventure / Collection / Reaction  
**Perspective:** Top-down / 3/4 View  
**Art Style:** 2D Pixel Art  
**Target Platform:** PC  
**Players:** Single-player first / Co-op 2–4 Players planned

---

# 1. Game Concept

## High Concept

Project Angler เป็นเกมตกปลา 2D Pixel Art แบบ Top-down ที่เน้น

**Exploration + Fishing + Reaction Challenge + Collection + Progression**

ผู้เล่นออกสำรวจโลกเพื่อค้นหาแหล่งตกปลา ปลาใหม่ เหยื่อ อุปกรณ์ และพื้นที่ลับ

เมื่อปลากินเบ็ด เกมจะเข้าสู่ **Fishing Battle**

Fishing Battle ไม่ใช้ระบบดึงเบ็ดแบบทั่วไป แต่ใช้ **Arrow Sequence Challenge**

เกมจะสุ่มชุดคำสั่ง

**← ↑ ↓ →**

ให้ผู้เล่นกดให้ถูกต้องภายในเวลาที่กำหนด

ปลาแต่ละชนิดสามารถมีกฎพิเศษ เช่น

- ลูกศรหาย
- ต้องกดทิศตรงข้าม
- มีลูกศรที่ห้ามกด
- ต้องจำ Sequence
- จำนวนรอบแตกต่างกัน

ยิ่งปลาหายาก การต่อสู้จะยิ่งมีกฎและ Pattern ที่ซับซ้อนขึ้น

---

# 2. Game Fantasy

ผู้เล่นควรรู้สึกเหมือนเป็นนักตกปลาที่เดินทางไปยังสถานที่ต่าง ๆ เพื่อค้นหาและพิชิตปลาหายาก

ช่วง Exploration ให้ความรู้สึก

**Relax / Discover / Prepare**

ช่วง Fishing Battle ให้ความรู้สึก

**Focus / React / Challenge**

หลังจับปลาได้ให้ความรู้สึก

**Reward / Collection / Progress**

Experience Loop:

**Relax → Discover → Bite! → Challenge → Catch → Reward → Explore**

---

# 3. Core Design Pillars

## 3.1 Fishing Skill

การจับปลาไม่ได้ขึ้นอยู่กับ Equipment เพียงอย่างเดียว

ผู้เล่นต้องใช้

- Reaction
- Attention
- Pattern Recognition
- Memory
- Decision Making

Equipment ช่วยลดความยากได้ แต่ไม่ควรเล่นแทนผู้เล่น

---

## 3.2 Fish Personality

ปลาแต่ละชนิดต้องให้ประสบการณ์แตกต่างกัน

ความแตกต่างเกิดจาก

- Arrow Pattern
- Sequence Length
- Modifier
- Time Limit
- Number of Rounds
- Behavior
- Visual Movement

---

## 3.3 Exploration

ผู้เล่นควรมีเหตุผลให้ออกสำรวจโลก

เพื่อค้นหา

- Fishing Spots
- Fish Species
- Rare Fish
- Bait
- Equipment
- NPC
- Secret Areas
- Legendary Fish

---

## 3.4 Collection

การค้นหาและสะสมปลาเป็นหนึ่งในเป้าหมายระยะยาว

ผู้เล่นสามารถพยายาม

- จับปลาให้ครบ
- หา Rare Variant
- ทำลายสถิติน้ำหนัก
- หา Legendary Fish

---

## 3.5 Progression

ผู้เล่นจะค่อย ๆ เข้าถึง

- Equipment ที่ดีขึ้น
- Bait ใหม่
- Fishing Spots ใหม่
- Area ใหม่
- Fish ที่ยากขึ้น

---

# 4. Core Gameplay Loop

```text
Explore
   ↓
Find Fishing Spot
   ↓
Choose Rod + Bait
   ↓
Cast
   ↓
Wait
   ↓
Fish Bite!
   ↓
Fishing Battle
   ↓
Catch / Escape
   ↓
Fish Collection
   ↓
Keep / Sell
   ↓
Upgrade Equipment
   ↓
Explore New Area
   ↓
Discover New Fish
   ↺
```

---

# 5. World Perspective

เกมใช้

**Top-down / 3/4 Perspective**

ตลอดทั้งเกม

ไม่มีการเปลี่ยนเป็น Side-view ขณะตกปลา

Perspective เดียวใช้สำหรับ

- Exploration
- Fishing
- NPC
- Shop
- Multiplayer

ช่วยลดจำนวน Asset และ Animation ที่ต้องสร้าง

---

# 6. Exploration

Player สามารถเดินได้ 4 ทิศ

**↑ ↓ ← →**

ผู้เล่นสามารถ

- เดินสำรวจ
- หา Fishing Spot
- คุยกับ NPC
- ซื้อของ
- เข้าอาคาร
- ค้นหา Secret Area
- เดินทางไป Map ใหม่

ตัวอย่าง:

```text
Village
   ↓
Forest
   ↓
พบทางแยก
   ↓
Hidden Path
   ↓
Secret Pond
   ↓
พบปลาที่ไม่มีในบ่อทั่วไป
```

---

# 7. World Structure

โครงสร้างเบื้องต้น:

```text
Village
│
├── Home
├── Fishing Shop
├── Fish Market
└── NPC
     │
     ▼
Small Pond
     │
     ▼
River
     │
     ▼
Forest Lake
     │
     ▼
Deep Lake
     │
     ▼
Coast
     │
     ▼
Ocean
```

แต่ละ Area มี

- Environment
- Fishing Spots
- Fish Pool
- Rare Fish
- Secret
- Music Theme

---

# 8. Fishing Spots

ผู้เล่นไม่สามารถตกปลาได้ทุกจุด

World มีพื้นที่ที่กำหนดเป็น Fishing Spot

เช่น

- Pond
- River
- Lake
- Pier
- Beach
- Deep Water

Fishing Spot กำหนด

- Fish Pool
- Water Type
- Water Depth
- Rarity Chance
- Required Equipment

บาง Fishing Spot สามารถซ่อนไว้ในโลกเพื่อสนับสนุน Exploration

---

# 9. Fishing Flow

Fishing ประกอบด้วย

```text
Idle
 ↓
Casting
 ↓
Waiting
 ↓
Bite
 ↓
Fishing Battle
 ↓
Caught / Escaped
```

---

# 10. Casting

Player ยืนใกล้ Fishing Spot

กด Fishing Action เพื่อเริ่มตกปลา

ระบบ Casting ใน Prototype สามารถเริ่มจากระบบง่าย ๆ ก่อน

ภายหลังสามารถเพิ่ม

**Hold → Cast Power**

```text
0%  [██████--------------] 100%
```

Cast Distance สามารถมีผลต่อ

- Water Depth
- Fish Pool
- Rare Fish Chance

---

# 11. Waiting

หลังจากโยนเบ็ด

เกมเลือกปลาโดยพิจารณาจาก

- Location
- Fishing Spot
- Bait
- Water Depth
- Time
- Weather
- Rarity

เมื่อปลากินเบ็ด:

**BITE!**

เข้าสู่ Fishing Battle

---

# 12. Fishing Battle

Fishing Battle คือ Main Mechanic ของเกม

Battle แบ่งเป็นหลาย **Round**

แต่ละ Round จะมี Arrow Sequence

ตัวอย่าง:

```text
ROUND 1

TIME
████████████████░░░

←   ↑   →   ↓
```

ผู้เล่นต้องกด

**← ↑ → ↓**

ตามลำดับภายในเวลาที่กำหนด

---

# 13. Round Flow

ตัวอย่างปลา 1 ตัว:

```text
BITE!

   ↓

ROUND 1

← ↑ →

SUCCESS

   ↓

ROUND 2

↓ → ← ↑

SUCCESS

   ↓

ROUND 3

↑ ← ↓ → ←

SUCCESS

   ↓

CAUGHT!
```

ถ้าผ่านทุก Round

→ Catch Fish

ถ้าล้มเหลวเกินจำนวนที่กำหนด

→ Fish Escape

---

# 14. Fishing Battle UI

ตัวอย่าง Layout:

```text
          CARP
       ★★ Uncommon

Catch
████████░░░░░░

        ROUND 2 / 3

      ←  ↑  →  ↓

      ✓  ✓  [→] ↓

TIME
██████████░░░░░

      1 Mistake
```

ผู้เล่นควรเห็นชัดเจนว่า

- กำลังจับปลาอะไร
- อยู่ Round ไหน
- ต้องกดอะไรต่อ
- เหลือเวลาเท่าไร
- ทำผิดไปกี่ครั้ง
- ใกล้จับปลาได้แค่ไหน

---

# 15. Base Arrow Rule

กฎพื้นฐาน:

เกมแสดง

```text
← ↑ → ↓
```

ผู้เล่นกด

```text
← ↑ → ↓
```

เรียงตามลำดับ

เมื่อกดถูก:

```text
←   ↑   →   ↓
✓   ✓   [→] ↓
```

ระบบให้ Feedback ทันที

---

# 16. Fishing Modifiers

ปลาที่ยากขึ้นสามารถมีกฎพิเศษ

Modifier เป็นหนึ่งในระบบหลักที่สร้างความแตกต่างระหว่างปลา

---

## 16.1 Normal

แสดงอะไร → กดแบบนั้น

```text
← ↑ → ↓
```

เหมาะกับปลาเริ่มต้น

---

## 16.2 Hidden

Arrow บางตัวจะหายไป

เริ่มต้น:

```text
← ↑ → ↓
```

หลังจากนั้น:

```text
← ? → ?
```

ผู้เล่นต้องจำ Arrow ที่หายไป

**Tests:** Memory

---

## 16.3 Flash

Sequence ทั้งชุดแสดงเพียงช่วงสั้น ๆ

```text
← ↑ ↓ →
```

หลังจากนั้น:

```text
? ? ? ?
```

ผู้เล่นต้องจำ Sequence ทั้งหมด

**Tests:** Short-term Memory

---

## 16.4 Reverse

ผู้เล่นต้องกดทิศตรงข้าม

Mapping:

```text
← → →
→ → ←
↑ → ↓
↓ → ↑
```

ตัวอย่าง:

แสดง:

```text
← ↑ →
```

ต้องกด:

```text
→ ↓ ←
```

**Tests:** Mental Processing

---

## 16.5 Forbidden

บาง Arrow ห้ามกด

ตัวอย่าง:

```text
←   ↑   →   ↓
✓   ✕   ✓   ✓
```

ผู้เล่นต้องกด

```text
← → ↓
```

ถ้ากด `↑`

→ Mistake

**Tests:** Attention / Inhibition

---

## 16.6 No Input

บาง Round ผู้เล่นต้องไม่กดอะไร

```text
DON'T MOVE

3
2
1
```

ถ้ากด Arrow

→ Mistake

ถ้าไม่กดจนหมดเวลา

→ Success

ใช้เป็น Pattern Break ไม่ควรใช้บ่อยเกินไป

---

# 17. Modifier Combination

ปลา Advanced สามารถมี Modifier มากกว่า 1 แบบ

ตัวอย่าง:

**Hidden + Reverse**

เกมแสดง

```text
← ↑ → ↓
```

บางตัวหาย:

```text
← ? → ?
```

และผู้เล่นต้องกดทิศตรงข้าม

---

อีกตัวอย่าง:

**Reverse + Forbidden**

```text
←   ↑   →   ↓
    ✕
```

ผู้เล่นต้อง

1. ข้าม Forbidden Arrow
2. Reverse ตัวที่เหลือ

Modifier Combination ควรใช้กับปลา Late-game เท่านั้น

---

# 18. Difficulty Model

ความยากไม่ได้มาจาก Rarity เพียงอย่างเดียว

Difficulty ประกอบด้วย

```text
Sequence Length
      +
Time Limit
      +
Number of Rounds
      +
Modifier
      +
Modifier Combination
```

---

# 19. Rarity

## Common

เป้าหมาย:

เรียนรู้ Gameplay

ประมาณ:

- 3–4 Arrows
- 2–3 Rounds
- Normal
- เวลาค่อนข้างเยอะ

---

## Uncommon

เริ่มทดสอบ Skill เพิ่ม

ประมาณ:

- 4–5 Arrows
- 3–4 Rounds
- Normal
- Hidden

---

## Rare

เริ่มมีกฎเฉพาะ

ประมาณ:

- 5–7 Arrows
- 3–5 Rounds

Modifier:

- Hidden
- Reverse
- Forbidden

---

## Epic

เริ่มผสม Mechanic

ประมาณ:

- 5–8 Arrows
- 4–6 Rounds

สามารถมี

- Flash
- Hidden + Reverse
- Reverse + Forbidden

---

## Legendary

ออกแบบเหมือน Boss Encounter

ไม่จำเป็นต้องใช้ Pure Random

สามารถมี

- Unique Pattern
- Multiple Phases
- Unique Modifier
- Modifier Combination
- Unique Music
- Unique Animation

---

# 20. Fish Behavior

นอกจาก Modifier ปลาแต่ละชนิดมี Behavior

## Calm

Sequence ค่อนข้างสม่ำเสมอ

เหมาะกับปลาเริ่มต้น

---

## Burst

บาง Round สั้น

บาง Round ยาวขึ้นอย่างกะทันหัน

---

## Heavy

ไม่ได้เร็วมาก

แต่ Battle มีหลาย Round

---

## Erratic

Sequence และ Modifier เปลี่ยนบ่อย

เหมาะกับปลา Rare

---

# 21. Example Fish

## Bluegill

**Rarity:** Common  
**Behavior:** Calm

```text
3 Arrows
2 Rounds
Normal
```

ใช้เป็น Tutorial Fish

---

## Carp

**Rarity:** Uncommon  
**Behavior:** Burst

```text
4–5 Arrows
3 Rounds

Normal
+
Hidden
```

---

## Catfish

**Rarity:** Uncommon  
**Behavior:** Heavy

```text
4–5 Arrows
4–5 Rounds
```

ไม่ได้เร็วมากแต่ต้องรักษาความแม่นยำนานกว่า

---

## Pike

**Rarity:** Rare  
**Behavior:** Erratic

```text
5–7 Arrows
3–5 Rounds

Normal
Hidden
Reverse
```

---

# 22. Legendary Fish

Legendary Fish ทำหน้าที่คล้าย Boss

ตัวอย่าง:

```text
LEGENDARY CATFISH

PHASE 1
Normal

← ↑ → ↓


PHASE 2
Hidden

← ? → ?


PHASE 3
Reverse

← ↑ → ↓


PHASE 4
Forbidden

←  ↑  →  ↓
✓  ✕  ✓  ✓


FINAL PHASE

Hidden + Reverse
```

Difficulty เพิ่มผ่าน Mechanic ไม่ใช่เพียงการเพิ่ม Arrow

---

# 23. Failure System

ผู้เล่นสามารถพลาดได้จำนวนหนึ่ง

ตัวอย่าง:

```text
Mistakes

♥ ♥ ♥
```

กดผิด:

```text
♥ ♥ ♡
```

พลาดครบ:

```text
FISH ESCAPED!
```

บาง Equipment สามารถเพิ่ม Error Tolerance ได้

ระบบนี้ต้อง Playtest ก่อนกำหนดจำนวนจริง

---

# 24. Timer

แต่ละ Round มีเวลาจำกัด

ตัวอย่าง:

```text
TIME

██████████████░░░
```

เวลาหมดก่อน Sequence สำเร็จ

→ Round Failed / Mistake

Timer จะเป็นหนึ่งใน Parameter หลักของ Difficulty

---

# 25. Music

Music ไม่ได้กำหนดจังหวะการกด Arrow

ไม่มี Requirement ให้ Input Sync กับ Beat

Music ทำหน้าที่

- สร้าง Atmosphere
- เพิ่ม Tension
- สื่อ Rarity
- สื่อ Fish Encounter
- ทำ Legendary Battle ให้น่าจดจำ

ทำให้ระบบ Audio ไม่ผูกติดกับ Input Logic

---

# 26. Equipment

Equipment ช่วยผู้เล่นแต่ไม่ควรลบ Skill Challenge

## Rod

สามารถมี

- Cast Distance
- Control
- Battle Time Bonus

ตัวอย่าง:

Starter Rod

`Time Bonus +0 sec`

Better Rod

`Time Bonus +0.3 sec`

---

## Fishing Line

มีผลต่อ Error Tolerance

ตัวอย่าง:

Basic Line

`Mistake Allowance: 1`

Strong Line

`Mistake Allowance: 2`

---

## Bait

Bait เปลี่ยนโอกาสพบปลา

ตัวอย่าง:

### Worm

Bluegill +++  
Carp ++  
Catfish +

### Shrimp

Bluegill +  
Carp ++  
Catfish +++

### Small Fish

Pike +++

---

# 27. Fish Collection

ผู้เล่นมี Fish Collection / Fish Book

ข้อมูล:

```text
Species
Rarity
Caught Count
Largest Size
Largest Weight
Best Grade
Habitat
Preferred Bait
```

ตัวอย่าง:

```text
BLUEGILL

Caught: ✓

Total: 18

Largest:
1.23 kg

Best Grade:
S

Location:
Small Pond
```

ปลาที่ยังไม่เคยพบ:

```text
?????

[Fish Silhouette]

Location:
Unknown
```

---

# 28. Economy

ปลาสามารถขายเพื่อรับเงิน

เงินใช้สำหรับ

- Rod
- Line
- Bait
- Equipment
- Area Access
- Cosmetic

Economy จะ Balance หลัง Core Gameplay ผ่าน Prototype แล้ว

---

# 29. Progression

```text
Small Pond
     ↓
Common Fish
     ↓
เรียนรู้ Arrow System
     ↓
Upgrade
     ↓
River
     ↓
Hidden Modifier
     ↓
Lake
     ↓
Reverse / Forbidden
     ↓
Deep Lake
     ↓
Rare / Epic Fish
     ↓
Ocean
     ↓
Legendary Fish
```

นี่ทำให้ **Progression สอน Mechanic ใหม่ไปพร้อมกัน**

---

# 30. Multiplayer

**Status: Future**

Target:

**2–4 Players**

ผู้เล่นอยู่ใน Top-down World เดียวกัน

แต่ละคนสามารถ

- Explore
- Shop
- Fish
- Catch Fish

ได้อิสระ

Player A สามารถกำลัง Fishing Battle ขณะที่ Player B เดินสำรวจได้

---

# 31. Cooperative Fishing

เก็บไว้สำหรับ Future Prototype

ปลาขนาดใหญ่หรือ Legendary บางชนิดอาจต้องใช้ผู้เล่นหลายคน

ตัวอย่าง:

```text
Legendary Fish

       ↓

Player 1
Normal Sequence

← ↑ → ↓


Player 2
Forbidden Sequence

← ✕↑ → ↓


       ↓

TEAM SUCCESS
```

Co-op Mechanic จะออกแบบหลัง Single-player Core Loop เสร็จ

---

# 32. MVP

## Objective

ตอบคำถามเดียว:

> Arrow Sequence Fishing สนุกพอที่จะเป็น Core Gameplay หรือไม่?

## MVP Content

```text
1 Player
1 Small Map
1 Fishing Spot

3 Fish
1 Rod
1 Bait
```

ปลา:

- Bluegill
- Carp
- Catfish

---

# 33. MVP Systems

ต้องมี:

- Top-down Movement
- Fishing Spot Interaction
- Casting
- Waiting
- Fish Bite
- Arrow Sequence Generator
- Arrow Input
- Round System
- Timer
- Normal Modifier
- Hidden Modifier
- Correct / Wrong Feedback
- Mistake System
- Catch
- Escape

---

# 34. Not In MVP

ยังไม่ทำ:

- Multiplayer
- Co-op Fishing
- Quest
- Crafting
- Boat
- Weather
- Day / Night
- Story
- Legendary Fish
- Huge World
- Complex Economy

Reverse และ Forbidden สามารถเพิ่มหลัง Normal + Hidden Prototype ผ่าน

---

# 35. Prototype Development

## Prototype 1

สร้างเฉพาะ:

```text
← ↑ ↓ →

Random Sequence
      ↓
Input
      ↓
Correct / Wrong
      ↓
Timer
      ↓
Round
      ↓
Win / Lose
```

ยังไม่ต้องมี Map

---

## Prototype 2

เพิ่ม:

```text
Normal
+
Hidden
```

---

## Prototype 3

เพิ่ม:

```text
Reverse
+
Forbidden
```

---

## Prototype 4

เชื่อมกับ Fishing:

```text
Cast
 ↓
Wait
 ↓
Bite
 ↓
Arrow Battle
 ↓
Catch
```

---

## Prototype 5

เพิ่ม Top-down World

```text
Explore
 ↓
Fishing Spot
 ↓
Fish
 ↓
Catch
```

---

# 36. Vertical Slice

หลัง Prototype ผ่านแล้ว

สร้างพื้นที่ Small Pond ให้เหมือนเกมจริง

ประกอบด้วย:

- Player Animation
- Small Pond Map
- 5–10 Fish
- Fishing
- Fish Collection
- Inventory
- Shop
- Sell Fish
- Rod Upgrade
- Bait
- Music
- Sound
- UI

เป้าหมายคือสร้าง Gameplay ประมาณ 15–30 นาทีที่ใกล้เคียงเกมจริง

---

# 37. Prototype Success Criteria

Prototype ถือว่าผ่านเมื่อ:

1. ผู้เล่นเข้าใจกฎ Arrow ได้ง่าย

2. Input รู้สึก Responsive

3. Timer สร้างความตื่นเต้นโดยไม่ Frustrating

4. Normal Sequence สนุกแม้ไม่มีระบบอื่น

5. Modifier ทำให้ Challenge เปลี่ยน ไม่ใช่แค่ยากขึ้น

6. ผู้เล่นสามารถเรียนรู้ Modifier จาก Gameplay

7. ปลาแต่ละชนิดให้ประสบการณ์แตกต่างกัน

8. Catch ให้ Feedback ที่น่าพอใจ

9. ผู้เล่นอยากลองจับปลาที่ยากขึ้น

---

# 38. Important Design Rules

## Rule 1

**Rare ≠ More Arrows Only**

ความยากต้องมาจากหลายระบบ

---

## Rule 2

**Readable Before Difficult**

ผู้เล่นต้องเข้าใจกฎก่อนเกมเพิ่มความยาก

---

## Rule 3

**Failure Must Feel Fair**

ผู้เล่นควรรู้ว่า

> “ฉันกดผิด”

ไม่ใช่

> “เกมหลอกฉัน”

---

## Rule 4

**Modifier = Fish Personality**

Modifier ควรสัมพันธ์กับปลา

ไม่ควร Random ทุกอย่างโดยไม่มีเหตุผล

---

## Rule 5

**Skill Before Equipment**

Equipment ช่วยได้

แต่ผู้เล่นที่เล่นเก่งควรสามารถจับปลายากได้ด้วย Skill

---

# 39. Open Design Questions

สิ่งที่ต้อง Prototype:

- Sequence แสดงทั้งหมดพร้อมกันหรือทีละ Arrow?
- Hidden หายบางตัวหรือทั้งหมด?
- Sequence แสดงกี่วินาทีก่อนเริ่ม?
- Timer ต่อ Round ควรประมาณเท่าไร?
- กดผิดควรเสีย Life หรือ Reset Round?
- จำนวน Mistake สูงสุดเท่าไร?
- Sequence Length สูงสุดเท่าไร?
- Forbidden Arrow ควรแสดงอย่างไร?
- Reverse Modifier ต้องมี Warning หรือไม่?
- Modifier Combination เริ่มใช้ช่วงไหน?
- ปลาแต่ละ Species มี Modifier ประจำตัวหรือสุ่มบางส่วน?
- Rare Variant ของปลาชนิดเดียวกันควรเปลี่ยน Modifier หรือ Stats?
- Equipment ช่วย Timer ได้มากแค่ไหน?
- Legendary Encounter ควรยาวกี่ Phase?

คำถามเหล่านี้จะตอบจาก Playtest ไม่ใช่กำหนดจาก GDD อย่างเดียว

---

# 40. Current Game Identity

## Project Angler

**Top-down Pixel Art Fishing Adventure**

Core Gameplay:

**Explore → Discover → Fish → React → Catch → Collect → Upgrade**

Fishing Battle:

**Arrow Sequence + Timer + Rounds + Modifiers**

Difficulty:

**Sequence + Time + Rounds + Rules**

Long-term Goal:

ค้นหาและจับปลาทุกชนิด รวมถึง Legendary Fish ที่มี Fishing Battle และกฎเฉพาะตัว
