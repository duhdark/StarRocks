# 🔓 Настройка частичного доступа к GitHub репозиторию

## Варианты настройки

### 1. **Публичный репозиторий (Рекомендуется)**

Самый простой способ для open-source проектов:

```bash
# В настройках GitHub репозитория
Settings → General → Repository visibility → Public
```

**Преимущества:**
- ✅ Полностью бесплатно
- ✅ Любой может просматривать код
- ✅ Можно клонировать без авторизации
- ✅ Хорошо для open-source проектов

### 2. **Приватный репозиторий + GitHub Pages**

Код остается приватным, но документация публична:

#### Шаг 1: Настройка GitHub Pages
```bash
# В настройках GitHub репозитория
Settings → Pages → Source → Deploy from a branch
# Выберите branch: gh-pages, folder: / (root)
```

#### Шаг 2: Настройка Actions
```bash
# GitHub Actions автоматически публикует документацию
# при каждом push в main branch
```

#### Шаг 3: Публичная документация
- Документация будет доступна по адресу: `https://username.github.io/StarRocks`
- Код остается приватным
- Только документация публична

### 3. **Приватный репозиторий + Collaborators**

Добавить конкретных пользователей:

```bash
# В настройках GitHub репозитория
Settings → Collaborators and teams → Add people
```

**Уровни доступа:**
- **Read** - только просмотр
- **Write** - просмотр + создание веток  
- **Admin** - полный доступ

### 4. **GitHub Releases**

Публиковать релизы с документацией:

```bash
# Создать release в GitHub
Releases → Create a new release
```

## 🎯 Рекомендуемое решение для StarRocks

### Вариант A: Публичный репозиторий

```bash
# 1. Сделать репозиторий публичным
Settings → General → Repository visibility → Public

# 2. Добавить описание
# StarRocks Docker Deployment - готовые конфигурации для развертывания

# 3. Добавить теги
# starrocks, docker, database, analytics, monitoring
```

### Вариант B: Приватный + GitHub Pages

```bash
# 1. Оставить репозиторий приватным
Settings → General → Repository visibility → Private

# 2. Настроить GitHub Pages
Settings → Pages → Source → Deploy from a branch → gh-pages

# 3. Настроить Actions (уже создан .github/workflows/docs.yml)

# 4. Публичная документация будет доступна по адресу:
# https://duhdark.github.io/StarRocks
```

## 📋 Пошаговая инструкция

### Для публичного репозитория:

1. **Перейти в настройки репозитория**
   ```
   https://github.com/duhdark/StarRocks/settings
   ```

2. **Изменить видимость**
   ```
   General → Repository visibility → Public
   ```

3. **Добавить описание**
   ```
   StarRocks Docker Deployment - готовые конфигурации для развертывания StarRocks в Docker
   ```

4. **Добавить теги**
   ```
   starrocks, docker, database, analytics, monitoring, devops
   ```

5. **Создать первый коммит**
   ```bash
   git add .
   git commit -m "Initial commit: StarRocks Docker deployment projects"
   git push origin main
   ```

### Для приватного репозитория с GitHub Pages:

1. **Оставить репозиторий приватным**

2. **Настроить GitHub Pages**
   ```
   Settings → Pages → Source → Deploy from a branch → gh-pages
   ```

3. **Проверить Actions**
   ```
   Actions → Deploy Documentation
   ```

4. **Публичная документация**
   ```
   https://duhdark.github.io/StarRocks
   ```

## 🔧 Дополнительные настройки

### Добавить Collaborators (если нужно):

```bash
# В настройках репозитория
Settings → Collaborators and teams → Add people

# Добавить пользователей с уровнем доступа:
# - Read (только просмотр)
# - Write (просмотр + создание веток)
# - Admin (полный доступ)
```

### Настроить Branch Protection:

```bash
# В настройках репозитория
Settings → Branches → Add rule

# Настроить защиту main branch:
# - Require pull request reviews
# - Require status checks to pass
# - Include administrators
```

## 📊 Статистика доступа

После настройки вы сможете видеть:
- Количество просмотров репозитория
- Количество клонирований
- Популярные файлы
- Географию пользователей

## 🎉 Результат

В зависимости от выбранного варианта:

**Публичный репозиторий:**
- ✅ Код виден всем
- ✅ Можно клонировать без авторизации
- ✅ Хорошо для open-source

**Приватный + GitHub Pages:**
- ✅ Код остается приватным
- ✅ Документация публична
- ✅ Контроль над доступом 