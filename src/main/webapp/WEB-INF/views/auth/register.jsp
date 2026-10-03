<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="ico" value="${ctx}/assets/images/icons.svg"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Create account | EmptyMiles</title>
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
        <h2>Create your account</h2>
        <p class="lead">Choose how you'll use EmptyMiles.</p>

        <c:if test="${not empty error}">
            <div class="alert alert-error" role="alert"><svg class="i"><use href="${ico}#alert"/></svg><span><c:out value="${error}"/></span></div>
        </c:if>

        <form method="post" action="${ctx}/register" class="validate" novalidate>
            <div class="role-choice">
                <label class="radio-card">
                    <input type="radio" name="role" value="CUSTOMER" ${param.role != 'PARTNER' ? 'checked' : ''}>
                    <span class="rc"><svg class="i"><use href="${ico}#package"/></svg><b>Send goods</b><small>I'm a customer</small></span>
                </label>
                <label class="radio-card">
                    <input type="radio" name="role" value="PARTNER" ${param.role == 'PARTNER' ? 'checked' : ''}>
                    <span class="rc"><svg class="i"><use href="${ico}#truck"/></svg><b>Deliver goods</b><small>I have a vehicle</small></span>
                </label>
            </div>
            <label class="field"><span>Full name</span>
                <input type="text" name="name" value="<c:out value='${param.name}'/>" autocomplete="name" required>
            </label>
            <div class="form-row">
                <label class="field"><span>Email</span>
                    <input type="email" name="email" value="<c:out value='${param.email}'/>" autocomplete="email" required>
                </label>
                <label class="field"><span>Phone <span class="hint">10 digits</span></span>
                    <input type="tel" name="phone" pattern="[0-9]{10}" value="<c:out value='${param.phone}'/>" autocomplete="tel" required>
                </label>
            </div>
            <div class="form-row">
                <label class="field"><span>Password <span class="hint">min 6</span></span>
                    <input type="password" name="password" minlength="6" autocomplete="new-password" required>
                </label>
                <label class="field"><span>Confirm password</span>
                    <input type="password" name="confirmPassword" minlength="6" data-match="password" autocomplete="new-password" required>
                </label>
            </div>
            <button type="submit" class="btn btn-primary btn-lg btn-block"><span>Create account</span></button>
        </form>
        <p class="switch">Already registered? <a href="${ctx}/login">Log in</a></p>
    </div>
</main>
<script src="${ctx}/assets/js/validation.js"></script>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
