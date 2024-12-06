# Dietary 👨‍🏫  

**Dietary**는 사용자가 건강한 생활을 유지할 수 있도록 식단과 체중을 기록하고 관리하는 애플리케이션입니다.  
사용자가 입력한 데이터에 따라 영양소 상태를 시각적으로 확인할 수 있으며, 체중 변화와 단식 시간을 기록해 더 나은 건강 목표를 달성할 수 있도록 돕습니다.  

---

## ⏲️ 개발 기간  
- **2024.11.11 (월)** ~ **2024.12.06 (금)**  

---

## 🧑‍🤝‍🧑 개발자 소개  
- **황준선** (2071104) 
- **주환수** (2071019) 
- **조민기** (2091315)  
- **박성현** (2171510)
- **최은비** (2271161)
  
---
  
## 💻 개발 환경  
- **Flutter**  
- **Dart**  
- **Firebase**  

---

## 주요 기능  

### 1️⃣ **회원가입 및 로그인**  
- **회원가입**  
  - 사용자 이름, 생년월일, 이메일, 비밀번호를 입력받아 회원가입.  
  - 이메일은 고유 식별자로 사용.  
  - 비밀번호는 최소 6자리 이상 입력 필요.  

- **로그인**  
  - 이메일과 비밀번호를 입력하여 로그인.  

---

### 2️⃣ **사용자 정보 입력**  
- 키, 나이, 몸무게, 성별 등의 정보를 입력.  
- 목표 체중 설정 가능.  
- 음수 값은 입력 불가.  

---

### 3️⃣ **메인 홈**  
- **식단 입력**  
  - 아침, 점심, 저녁, 간식으로 구분하여 섭취 음식을 기록.  
  - 음식 목록 선택 또는 음식 등록 화면에서 직접 입력 가능.  

- **영양소 관리**  
  - 음식별 칼로리, 탄수화물, 단백질 데이터를 저장.  
  - 즐겨찾기 기능으로 자주 먹는 음식 관리.  
  - 날짜별 영양소 섭취량을 그래프로 확인.  
  - 초과 섭취 시 그래프에 **빨간색** 표시.  

- **다이어터 커뮤니티**  
  - 오른쪽에서 왼쪽으로 드래그하여 다이어트 정보를 사용자들끼리 공유.  

---

### 4️⃣ **마이페이지**  
- **내 정보 확인**  
  - 이름, 나이, 성별, 키, 현재 몸무게, 목표 체중 확인.  
- **프로필 사진 및 내정보 변경**  
  - 갤러리에서 프로필 사진 선택 후 변경.  
  - 나이, 키, 현재 몸무게, 목표 몸무게 수정 가능.  

---

### 5️⃣ **알림 기능**  
- 아침, 점심, 저녁 식사 시간 알림 설정 가능.  
- **단식 시간 기록**  
  - 단식 시작과 종료 시 알림 제공.  

---

### 6️⃣ **제철 음식 추천**  
- 사용자의 지역과 계절 정보를 바탕으로 제철 음식을 추천.  

---


# Dietary UI 소개 ✨  

Dietary의 주요 UI 화면은 다음과 같습니다:

---

## 1️⃣ 로그인 페이지 ~ 3️⃣ 회원 정보 입력 페이지
<div style="display: flex; flex-wrap: wrap; justify-content: center;">
    <div style="margin: 10px;">
        <img src="https://raw.githubusercontent.com/BlueH-01/dietary2/main/screenshots/KakaoTalk_20241206_140222228.jpg" alt="로그인 페이지" width="200">
        <p align="center">로그인 페이지</p>
    </div>
    <div style="margin: 10px;">
        <img src="https://raw.githubusercontent.com/BlueH-01/dietary2/main/screenshots/KakaoTalk_20241206_140222228_01.jpg" alt="회원가입 페이지" width="200">
        <p align="center">회원가입 페이지</p>
    </div>
    <div style="margin: 10px;">
        <img src="https://raw.githubusercontent.com/BlueH-01/dietary2/main/screenshots/KakaoTalk_20241206_140222228_02.jpg" alt="회원정보 입력 페이지" width="200">
        <p align="center">회원 정보 입력 페이지</p>
    </div>
</div>

---

## 4️⃣ 영양 관리 페이지 ~ 6️⃣ 음식 등록 및 즐겨찾기 목록
<div style="display: flex; flex-wrap: wrap; justify-content: center;">
    <div style="margin: 10px;">
        <img src="https://raw.githubusercontent.com/BlueH-01/dietary2/main/screenshots/KakaoTalk_20241206_140222228_03.jpg" alt="영양 관리 페이지" width="200">
        <p align="center">영양 관리 페이지</p>
    </div>
    <div style="margin: 10px;">
        <img src="https://raw.githubusercontent.com/BlueH-01/dietary2/main/screenshots/KakaoTalk_20241206_140222228_04.jpg" alt="달력 페이지" width="200">
        <p align="center">달력 페이지</p>
    </div>
    <div style="margin: 10px;">
        <img src="https://raw.githubusercontent.com/BlueH-01/dietary2/main/screenshots/KakaoTalk_20241206_140222228_05.jpg" alt="음식 등록 및 즐겨찾기" width="200">
        <p align="center">음식 등록 및 즐겨찾기</p>
    </div>
</div>

---

## 7️⃣ 음식 등록2 ~ 9️⃣ 식사 알림
<div style="display: flex; flex-wrap: wrap; justify-content: center;">
    <div style="margin: 10px;">
        <img src="https://raw.githubusercontent.com/BlueH-01/dietary2/main/screenshots/KakaoTalk_20241206_140222228_06.jpg" alt="음식 등록2" width="200">
        <p align="center">음식 등록2</p>
    </div>
    <div style="margin: 10px;">
        <img src="https://raw.githubusercontent.com/BlueH-01/dietary2/main/screenshots/KakaoTalk_20241206_140222228_07.jpg" alt="내 정보 수정" width="200">
        <p align="center">내 정보 수정</p>
    </div>
    <div style="margin: 10px;">
        <img src="https://raw.githubusercontent.com/BlueH-01/dietary2/main/screenshots/KakaoTalk_20241206_140222228_08.jpg" alt="식사 알림" width="200">
        <p align="center">식사 알림</p>
    </div>
</div>

---

## 🔟 커뮤니티 알림 ~ 1️⃣2️⃣ 운동 추천
<div style="display: flex; flex-wrap: wrap; justify-content: center;">
    <div style="margin: 10px;">
        <img src="https://raw.githubusercontent.com/BlueH-01/dietary2/main/screenshots/KakaoTalk_20241206_140222228_09.jpg" alt="커뮤니티 알림" width="200">
        <p align="center">커뮤니티 알림</p>
    </div>
    <div style="margin: 10px;">
        <img src="https://raw.githubusercontent.com/BlueH-01/dietary2/main/screenshots/KakaoTalk_20241206_140222228_10.jpg" alt="게시글 작성" width="200">
        <p align="center">게시글 작성</p>
    </div>
    <div style="margin: 10px;">
        <img src="https://raw.githubusercontent.com/BlueH-01/dietary2/main/screenshots/KakaoTalk_20241206_140222228_11.jpg" alt="운동 추천" width="200">
        <p align="center">운동 추천</p>
    </div>
</div>






