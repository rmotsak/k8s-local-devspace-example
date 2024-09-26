# Kubernetes Voting App Example

Цей репозиторій містить конфігурацію та інструкції для локального розгортання тестового додатку [example-voting-app](https://github.com/dockersamples/example-voting-app) у кластері Kubernetes з використанням інструментів Docker, K3d, DevSpace та Helm.

## Необхідні інструменти

Перед початком роботи переконайтеся, що у вас встановлені наступні інструменти:

1. **Docker**: платформа для контейнеризації додатків.
   - Інструкції з встановлення: [Docker Installation Guide](https://docs.docker.com/get-docker/)

2. **K3d**: легкий інструмент для створення кластерів Kubernetes на базі Docker.
   - Інструкції з встановлення: [K3d Installation Guide](https://k3d.io/#installation)

3. **DevSpace**: інструмент для прискорення розробки та деплойменту додатків у Kubernetes.
   - Інструкції з встановлення: [DevSpace Installation Guide](https://devspace.sh/cli/docs/getting-started/installation)

4. **kubectl**: клієнт для управління кластерами Kubernetes.
   - Інструкції з встановлення: [kubectl Installation Guide](https://kubernetes.io/docs/tasks/tools/)

5. **Helm** (опціонально): менеджер пакетів для Kubernetes.
   - Інструкції з встановлення: [Helm Installation Guide](https://helm.sh/docs/intro/install/)

6. **Lens** (опціонально): графічний інтерфейс для управління кластерами Kubernetes.
   - Інструкції з встановлення: [Lens Installation Guide](https://k8slens.dev/)

## Оригінальний репозиторій

Тестовий додаток, який ми будемо розгортати, розташований у директорії `src` та взятий з офіційного репозиторію:

[example-voting-app](https://github.com/dockersamples/example-voting-app)

## Налаштування локального середовища

### 1. Створення кластера Kubernetes за допомогою K3d

Для створення нового кластеру K3d виконайте наступну команду:

```
k3d cluster create mycluster
```

Перевірте, чи успішно створено кластер:

```
kubectl get nodes
```

### 2. Ініціалізація DevSpace вперше

Для того, щоб DevSpace почав працювати з вашим проектом, спочатку потрібно ініціалізувати його. Це налаштує середовище розробки для автоматичного розгортання додатка.

```
devspace init
```

Під час ініціалізації вам буде запропоновано відповісти на кілька питань, таких як:
- Тип проєкту (ви можете вибрати "Кубернетес" або Docker-файл).
- Параметри конфігурації контейнера та середовища.

Після цього DevSpace створить конфігураційний файл `devspace.yaml`, який буде використовуватись для автоматизації всіх процесів розгортання.

### 3. Розгортання додатку за допомогою DevSpace

Щоб розпочати роботу з додатком і розгорнути його у вашому локальному кластері, використовуйте наступну команду:

```
devspace dev
```

Ця команда:
- Автоматично збере контейнер, якщо це необхідно.
- Розгорне додаток у кластері.
- Налаштує синхронізацію файлів між локальним середовищем і кластером.
- Відкриє порти для доступу до додатку через браузер або API.

### 4. Взаємодія з DevSpace під час розробки

Під час роботи з DevSpace всі зміни в коді синхронізуються з вашим кластером у реальному часі. Якщо ви вносите зміни у файл, DevSpace автоматично застосує ці зміни до запущеного додатку в кластері без необхідності його перезавантаження.

### 5. Перезапуск DevSpace після внесення змін

Якщо ви вносите глобальні зміни в конфігурацію або хочете перезапустити весь процес розробки, ви можете перезапустити DevSpace за допомогою тієї ж команди:

```
devspace dev
```

Це повторно запустить процес розгортання і синхронізації, що дозволить вам бачити всі оновлення у вашому додатку.

### 6. Відкат змін у DevSpace

Якщо після внесення змін ви хочете відкотити додаток до початкового стану або припинити роботу DevSpace, використовуйте наступну команду для завершення сесії розробки:

```
devspace purge
```

Ця команда видалить усі ресурси, створені DevSpace, включаючи поди, сервіси та конфігурації, залишаючи ваш кластер у початковому стані.

### 7. Використання Helm (опціонально)

Якщо ви хочете використовувати Helm для управління додатками, наприклад для встановлення PostgreSQL, ви можете виконати наступну команду:

```
helm install my-postgres bitnami/postgresql
```

### 8. Доступ до додатку через port-forwarding

Для доступу до додатку з локальної машини використовуйте `kubectl port-forward`:

```
kubectl port-forward service/voting-app-service 8080:80
```

### 9. Перевірка статусу подів і сервісів

Для перевірки статусу подів:

```
kubectl get pods
```

Для перевірки статусу сервісів:

```
kubectl get services
```

## Додаткові команди

- Видалення кластера K3d:

```
k3d cluster delete mycluster
```

- Очищення всіх ресурсів, створених DevSpace:

```
devspace purge
```

## Приклади конфігурацій

### Як використати ConfigMap
- Створення ConfigMap

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgres://localhost:5432/mydb"
  log_level: "info"
```

- Використання ConfigMap

```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mycontainer
    image: myapp:latest
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: log_level
```

### Як використати Secret
- Створення Secret

```
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  username: YWRtaW4=  # Значення повинні бути закодовані в Base64
  password: cGFzc3dvcmQ=
```

- Використання Secret

```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mycontainer
    image: myapp:latest
    env:
    - name: USERNAME
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: username
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: password
```

### Як налаштувати автоматичне збільшення кількості Pod-ів при збільшенні навантаження
- Створення Horizontal Pod Autoscaler (HPA)

```
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: voting-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: voting-app
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50  # Масштабування на основі використання CPU

```

### Як користуватись RBAC (Role-Based Access Control)
- Створення ролі (Role)

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

- Створення RoleBinding (зв'язування ролі з користувачем або групою)

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

- Налаштування ServiceAccount для додатку

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: myapp-service-account
  namespace: app-namespace
```

- Налаштування ролі (Role)

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: target-namespace
  name: access-service
rules:
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list"]
```

- Зв'язування ролі з ServiceAccount через RoleBinding

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: bind-access-service
  namespace: target-namespace
subjects:
- kind: ServiceAccount
  name: myapp-service-account
  namespace: app-namespace  # ServiceAccount знаходиться в іншому namespace
roleRef:
  kind: Role
  name: access-service
  apiGroup: rbac.authorization.k8s.io
```

- Призначення ServiceAccount

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: app-namespace
spec:
  replicas: 1
  template:
    spec:
      serviceAccountName: myapp-service-account  # Призначаємо ServiceAccount
      containers:
      - name: myapp-container
        image: myapp-image:latest
```