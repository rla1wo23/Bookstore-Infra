# STC LABS과제

urg: No

책 목록 CRUD기능을 구현하고, 이 비즈니스 로직이 동작하는 인프라 환경을 구현하는 MSA입니다. (프로젝트명 bookstore)

## 아키텍처

---

![architect.drawio.png](hw/architect.drawio.png)

전반적인 아키텍처 설명입니다.

1. 최소기능의 프런트엔드를 구현했습니다. 이용자는 CloudFront와 연결돼있는 S3버킷을 통해 정적 파일에 접근할 수 있습니다.
2. VPC구성:
   1. Public Subnet: NAT Gateway, Bastion Host, VPN Server, Loadbalancer
   2. Private Subnet: Worker Nodes(Backends), RDS
3. 백엔드는 EKS클러스터로 배포돼있으며, 서비스 타입은 로드밸런서입니다.
4. 이 클러스터의 워커노드는 desired count=2, min=1, max=3으로 스케일링되게끔 설정돼 있습니다.
5. 모니터링서버에 grafana-prometheus가 간단하게 설정돼있습니다. 백엔드 이미지의 side-car로 prometheus node-exporter를 배포했고, 아주 간단한 메트릭만 수집하게끔 배포했습니다. (실제로 메트릭 수집 설정 yaml파일 작성은 진행하지 않았고, 인프라 프로비저닝까지는 헀습니다.)
6. OpenVPN AMI를 구독하고, vpn서버를 통해야 모니터링서버에 접근할 수 있게끔 했습니다.
7. BastionHost를 두어, 백엔드 어플리케이션 vpc에 진입할 수 있게끔 했습니다.

순서대로 설명하겠습니다.

## 최소 기능 프런트엔드

---

![image.png](hw/image.png)

프런트엔드는 과제의 요구사항은 아니었지만, CRUD를 클라이언트쪽에서 호출하는 로직이 실제 서비스 상황과 보다 유사할 것 같아서 간단하게나마 작성했습니다.

![image.png](hw/image%201.png)

폴더 구조는 위와 같고, 직관적으로 CRUD 비즈니스로직 엔드포인트를 호출할 수 있게끔 했습니다.

![image.png](hw/image%202.png)

여기서, API_URL은 배포 환경에서는 k8s 로드밸런서 서비스의 DNS로 바꿔 주어야 합니다.

![image.png](hw/image%203.png)

S3버킷에 배포하고, CloudFront에 연동하여 이 버킷의 퍼블릭 액세스 허용-액세스 엔드포인트 생성-CloudFront통합 배포 순으로하여 접근할 수 있습니다.

리소스의 프로비저닝 과정은 S3.tf에 작성해 두었습니다.

## VPC구성에 대한 설명

---

![image.png](hw/image%204.png)

- 두 가용영역(a, b)를 이용하였으며, 각각 프라이빗 서브넷과 퍼블릭 서브넷이 존재합니다.
  - EKS클러스터는 두 가용영역 내 프라이빗 서브넷에서 스케일링할 수 있습니다.
- Private Subnet:백엔드, DB 등의 비즈니스 로직이 포함된 리소스는 프라이빗 서브넷에 프로비저닝해 퍼블릭 액세스를 막는 것이 일반적인 접근입니다. VPC 내 프라이빗 서브넷에 비즈니스 로직이 배포돼 있습니다. 또, 모니터링 서버도 배포해서 클러스터 내 메트릭을 수집하고, grafana로 시각화합니다.
- Public Subnet: Bastion Host와 VPN서버가 프로비저닝 돼 있습니다. (VPN은 프라이빗 서브넷에 배포돼 있는 모니터링 서버를 운영자가 접근하기 위한 용도입니다.). 또, natgw가 배포돼 있는 것을 위 라우팅 리소스맵에서 보실 수 있습니다.
  ![image.png](hw/image%205.png)

cluster의 백엔드와 (현재 scale==1이어서 1개입니다.) , 모니터링 서버는 프라이빗 서브넷에, 배스천 호스트와 vpn서버는 퍼블릭에 배포돼 있습니다.

## EKS클러스터(쿠버네티스)

---

![image.png](hw/image%206.png)

hpa로 desired=2, min=1, max=3으로 스케일링되게끔 설정했습니다.

![image.png](hw/image%207.png)

사용된 백엔드 이미지와 도커파일 등은 작성한 helm차트와 yaml파일에서 확인하실 수 있습니다.

인프라 프로비저닝은 마찬가지로 terraform으로 수행했습니다. 비밀 관련된 부분은, base-64로 인코딩해서 제출했습니다. 원래는 kubectl create configmap backend-config --from-env-file=.env과 같이, yaml이 아닌 ad-hoc방식으로 비밀을 관리하는 것이 더 안전하다고 생각해서 이렇게 하는데, 일단 가독성을 위해서 db-secret.yaml을 작성해서 레포지토리에 올려두었습니다.

## 백엔드 이미지 설명

---

간단한 CRUD를 구현했습니다. 깃허브에서 확인하실 수 있고, 환경 변수는 아래와 같이 .env에 서 참조될 수 있게끔 하여 소스코드에 비밀이 누출되는 것을 막고, 환경변수 파일을 통해서 DB엔드포인트를 유동적으로 조절할 수 있게끔 했습니다.

![image.png](hw/image%208.png)

## DB Instance (RDS)

---

Mysql 기반의 RDS입니다.

![image.png](hw/image%209.png)

DB 스키마는 다음과 같습니다.
id INT AUTO_INCREMENT PRIMARY KEY, title VARCHAR(255), author VARCHAR(255), price DECIMAL(10, 2)
