<%@ include file="header.jsp" %>
<script type="text/javascript" src="http://maps.google.com/maps?file=api&v=2&key=${initParam['api-key']}" /></script>
<script type="text/javascript" src="http://google-maps-utility-library-v3.googlecode.com/svn/trunk/keydragzoom/src/keydragzoom_packed.js" /></script>
<script type="text/javascript" src="js/openlayers/OpenLayers.js" /></script>
<script type="text/javascript" src="js/oztrackmaps.js" /></script>

<h1><c:out value="${project.title}"/></h1>

    <div class="mapTool">
        <div id="projectMap"></div>
        <div id="projectMapOptions"></div>
        <div class="clearboth">&nbsp;</div>
    </div>



   <p style="color:red;"><c:out value="${errorStr}"/></p>



   <div style="border: 1px solid red;">
       <c:forEach items="${posFixNames}" var="name">
        <c:out value="${name} "/>
       </c:forEach>

       <c:forEach items="${rData}" var="r">
        <c:forEach items="${r}" var="x">
         <c:out value="${x}"/> <br>
        </c:forEach>
       </c:forEach>
   </div>

    <div style="border: 1px solid green;">

       <c:forEach items="${animalRefNames}" var="animal">
          <c:out value="${animal} "/>
       </c:forEach>

       <c:forEach items="${rAnimals}" var="a">
        <c:forEach items="${a}" var="s">
         <c:out value="${s}"/> <br>
        </c:forEach>
       </c:forEach>

      </div>

   <c:out value="${rOutput}"/>
<%@ include file="footer.jsp" %>
