import { setGlobalOptions } from "firebase-functions";
import { https } from "firebase-functions";
import * as admin from "firebase-admin";

setGlobalOptions({ maxInstances: 4 });
admin.initializeApp();

exports.notificarSolicitacaoPagamento = https.onCall(async (data, context) => {
    const notaId = data.data.notaId;

    if (!notaId) {
        throw new https.HttpsError(
            "invalid-argument",
            "A função precisa do parâmetro 'notaId'.",
        );
    }

    try {
        // 1. Buscar a nota para obter o ID do cliente
        const notaDoc = await admin.firestore().collection("notas").doc(notaId).get();
        if (!notaDoc.exists) {
            throw new https.HttpsError("not-found", "Nota não encontrada.");
        }
        const clienteId = notaDoc.data()!.clienteId;

        // 2. Buscar o cliente para obter o nome
        const clienteDoc = await admin.firestore().collection("clientes").doc(clienteId).get();
        const clienteNome = clienteDoc.exists ? clienteDoc.data()?.nome : "Um cliente";

        // 3. Criar o documento na coleção de solicitações
        await admin.firestore().collection("solicitacoes").add({
            notaId: notaId,
            clienteNome: clienteNome,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            status: "pendente",
        });

        const usersSnapshot = await admin.firestore().collection("users").get();
        const tokens = usersSnapshot.docs.map((doc) => doc.data().fcmToken);

        if (tokens.length === 0) {
            console.log("Nenhum dispositivo registrado para notificar.");
            return { success: true, message: "Solicitação registrada, mas sem dispositivos para notificar." };
        }

        // 4. Preparar e enviar a notificação
        const message = {
            notification: {
                title: "Solicitação de Pagamento 💸",
                body: `${clienteNome} solicitou o fechamento da conta!`,
            },
            tokens: tokens,
        };

        await admin.messaging().sendEachForMulticast(message);

        return { success: true };
    } catch (error) {
        console.error("Erro ao processar solicitação:", error);
        throw new https.HttpsError(
            "internal",
            "Não foi possível processar a solicitação.",
            error,
        );
    }
});
