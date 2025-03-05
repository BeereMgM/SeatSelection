document.addEventListener("DOMContentLoaded", function () {
    window.addEventListener("message", function (event) {

        if (event.data.action === "openUI") {
            const container = document.getElementById("seat-container");
            const uiContainer = document.getElementById("ui-container");

            if (!container || !uiContainer) {
                console.error("UI-Container oder Seat-Container nicht gefunden!");
                return;
            }

            container.innerHTML = "";

            let rowDiv = null; 
            for (let i = 1; i <= event.data.seats; i++) {
                if (i % 2 !== 0) {
                    rowDiv = document.createElement("div");
                    rowDiv.classList.add("seat-row");
                    container.appendChild(rowDiv);
                }

                let seatDiv = document.createElement("div");
                seatDiv.classList.add("seat");
                seatDiv.textContent = i;
                seatDiv.onclick = () => {
                    fetch(`https://${GetParentResourceName()}/selectSeat`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ seat: i, vehicle: event.data.vehicle })
                    });
                    
                    const uiContainer = document.getElementById("ui-container");
                    if (uiContainer) {
                        uiContainer.style.display = "none";
                    }
                } 
                
    

                if (rowDiv) {
                    rowDiv.appendChild(seatDiv);
                }
            }

            uiContainer.style.display = "block"; 
        }
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape") {
            fetch(`https://${GetParentResourceName()}/closeUI`, {
                method: "POST",
                headers: { "Content-Type": "application/json" }
            });

            const uiContainer = document.getElementById("ui-container");
            if (uiContainer) {
                uiContainer.style.display = "none";
            }
        }
    });
});
