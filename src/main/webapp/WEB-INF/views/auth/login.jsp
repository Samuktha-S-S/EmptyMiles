<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="ico" value="${ctx}/assets/images/icons.svg"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Log in | EmptyMiles</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap">
    <link rel="stylesheet" href="${ctx}/assets/css/style.css">
    <link rel="stylesheet" href="${ctx}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${ctx}/assets/css/auth.css">
</head>
<body class="auth-page">
<jsp:include page="/WEB-INF/views/includes/auth-brand.jsp"/>
<main class="auth-main">
    <div class="auth-card">
        <div class="auth-mobile-brand">
            <span class="brand"><span class="brand-mark"><svg class="i"><use href="${ico}#route"/></svg></span><span>EMPTY<b>MILES</b></span></span>
        </div>
        <h2>Welcome back</h2>
        <p class="lead">Log in to manage your shipments and deliveries.</p>

        <c:if test="${not empty sessionScope.flash}">
            <div class="alert alert-success"><svg class="i"><use href="${ico}#check-circle"/></svg><span><c:out value="${sessionScope.flash}"/></span></div>
            <c:remove var="flash" scope="session"/>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-error" role="alert"><svg class="i"><use href="${ico}#alert"/></svg><span><c:out value="${error}"/></span></div>
        </c:if>

        <form method="post" action="${ctx}/login" class="validate" novalidate>
            <label class="field"><span>Email</span>
                <span class="input-icon"><svg class="i"><use href="${ico}#mail"/></svg>
                    <input type="email" name="email" value="<c:out value='${param.email}'/>" placeholder="you@example.com" autocomplete="email" required autofocus></span>
            </label>
            <label class="field"><span>Password</span>
                <span class="input-icon"><svg class="i"><use href="${ico}#lock"/></svg>
                    <input type="password" name="password" placeholder="Your password" autocomplete="current-password" required></span>
            </label>
            <button type="submit" class="btn btn-primary btn-lg btn-block"><span>Log in</span></button>
        </form>
        <p class="switch">New to EmptyMiles? <a href="${ctx}/register">Create an account</a></p>
    </div>
</main>
<script src="${ctx}/assets/js/validation.js"></script>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
