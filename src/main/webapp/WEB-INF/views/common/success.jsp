<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="Done"/>
    <jsp:param name="nav" value="delivery"/>
</jsp:include>
<div class="card" style="max-width:560px;margin:40px auto 0">
    <div class="success-hero">
        <div class="check"><svg class="i"><use href="${ico}#check"/></svg></div>
        <h2>All done</h2>
        <p><c:out value="${message}"/></p>
        <a class="btn btn-primary" style="margin-top:18px" href="${ctx}${empty backUrl ? '/login' : backUrl}"><span>Continue</span></a>
    </div>
</div>
<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
