# CancellableNetwork

비동기 네트워킹 처리를 연습하기 위해 만든 어플

## 목표

아래 사항들을 연습합니다.

- [Lorem Picsum](https://picsum.photos)에서 2,000x1,000 크기를 가진 무작위 사진 5장을 받아 옵니다. 성능을 위해 동시에 5장을 받지 않고 최대 2개까지만 다운로드가 가능합니다.

- 사진을 받아 오기 위해 필요한 코드는 최대한 Main Thread에서 돌지 않도록 합니다. 비동기를 적극적으로 활용합니다.

- Race Condition은 없어야 합니다.

- Objective-C를 사용해야 하며 Automatic Reference Counting과 Weak Reference 설정을 비활성화 합니다. Over Releasing 및 Memory Leak은 없어야 합니다.

- 작업을 취소할 수 있어야 합니다.

## 배운 점

- `NSMutableArray`는 Thread Safe를 보장하지 않습니다. Lock을 걸거나 `@synchronized`로 해결해야 합니다.

- Automatic Reference Counting을 비활성화한 환경에서는 `dispatch_object_t`도 직접 메모리 관리를 해줘야 합니다. 이걸 모르고 헤매다가 `free` 호출해주니 크래시가 발동해서 한참을 고민했음... ([dispatch_retain](https://developer.apple.com/documentation/dispatch/1496306-dispatch_retain) / [dispatch_release](https://developer.apple.com/documentation/dispatch/1496328-dispatch_release))

## 스크린샷

![](image.png)
