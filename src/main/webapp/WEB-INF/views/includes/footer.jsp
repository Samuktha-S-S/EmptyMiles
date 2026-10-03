<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <footer class="footer">EmptyMiles &middot; Goods ride along on vehicles already on the road</footer>
    </main>
<c:if test="${not empty sessionScope.user}">
    </div>
</c:if>
</div>

<%-- Shared confirm dialog, opened by buttons with data-confirm="..." (see app.js) --%>
<div class="modal" id="confirmModal" role="dialog" aria-modal="true" aria-labelledby="confirmTitle">
    <div class="modal-card">
        <div class="modal-head">
            <div>
                <h2 id="confirmTitle" data-confirm-title>Are you sure?</h2>
                <p data-confirm-body></p>
            </div>
            <button type="button" class="modal-close" data-modal-close aria-label="Close">
                <svg class="i"><use href="${pageContext.request.contextPath}/assets/images/icons.svg#x"/></svg>
            </button>
        </div>
        <div class="modal-foot" style="padding-top:20px">
            <button type="button" class="btn btn-outline" data-modal-close>Cancel</button>
            <button type="button" class="btn btn-primary" data-confirm-ok>Confirm</button>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/validation.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>
