<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Register | EmptyMiles</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
</head>
<body class="auth-page">
<div class="auth-card">
    <h1 class="brand">Empty<span>Miles</span></h1>
    <p class="tagline">Create your account</p>

    <c:if test="${not empty error}">
        <div class="alert alert-error"><c:out value="${error}"/></div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/register" class="validate">
        <div class="role-choice">
            <label class="radio-card">
                <input type="radio" name="role" value="CUSTOMER" ${param.role != 'PARTNER' ? 'checked' : ''}>
                <span>I want to send goods<br><small>Customer</small></span>
            </label>
            <label class="radio-card">
                <input type="radio" name="role" value="PARTNER" ${param.role == 'PARTNER' ? 'checked' : ''}>
                <span>I have a vehicle<br><small>Delivery partner</small></span>
            </label>
        </div>
        <label>Full name
            <input type="text" name="name" value="<c:out value='${param.name}'/>" required>
        </label>
        <label>Email
            <input type="email" name="email" value="<c:out value='${param.email}'/>" required>
        </label>
        <label>Phone (10 digits)
            <input type="tel" name="phone" pattern="[0-9]{10}" value="<c:out value='${param.phone}'/>" required>
        </label>
        <label>Password (min 6 characters)
            <input type="password" name="password" minlength="6" required>
        </label>
        <label>Confirm password
            <input type="password" name="confirmPassword" minlength="6" data-match="password" required>
        </label>
        <button type="submit" class="btn btn-primary btn-block">Register</button>
    </form>
    <p class="switch">Already registered? <a href="${pageContext.request.contextPath}/login">Login</a></p>
</div>
<script src="${pageContext.request.contextPath}/assets/js/validation.js"></script>
</body>
</html>
