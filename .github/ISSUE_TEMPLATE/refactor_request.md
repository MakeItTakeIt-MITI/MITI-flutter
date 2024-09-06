---
name: 🔨 Refactor request
about: 코드 리팩토링 요청
title: "[REFACTOR] "
labels: refactor
assignees: ''

---

## 리팩토링할 부분
리팩토링이 필요한 코드 부분을 명확히 기술해 주세요.

## 리팩토링 이유
이 부분을 왜 리팩토링해야 하는지 설명해 주세요.
- 코드 개선 이유 (가독성, 성능 향상, 유지보수 용이성 등)
- 현재 문제점 또는 비효율적인 코드

## 리팩토링 방안
리팩토링 시 고려할 방안이나 방법을 설명해 주세요.

## 예상 결과
리팩토링 후 기대되는 결과를 명시해 주세요.
- 코드 가독성 향상
- 성능 개선
- 버그 수정 가능성 등

## 관련된 코드
리팩토링 대상 코드의 링크 또는 스니펫을 제공해 주세요.
```cpp
// 예시: 리팩토링이 필요한 코드 스니펫
function inefficientFunction() {
  for (let i = 0; i < array.length; i++) {
    if (array[i] === target) {
      return i;
    }
  }
  return -1;
}