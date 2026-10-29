import { supabase } from "../_lib/supabase.js";
import { getUserFromRequest } from "../_lib/auth.js";
import { handleCors } from "../_lib/cors.js";

/**
 * =========================================================
 * NEXTORI — API MES PISTES
 * =========================================================
 *
 * Endpoints :
 *
 * GET    /api/pistes
 * GET    /api/pistes/check
 * POST   /api/pistes
 * DELETE /api/pistes/:id
 *
 * Une piste peut être :
 * - un métier
 * - une filière
 *
 * Les deux types sont stockés dans la même table
 * piste_utilisateur, mais restent séparés fonctionnellement.
 *
 * J'hésite comparera :
 * - métier avec métier
 * - filière avec filière
 *
 * Jamais métier avec filière.
 * =========================================================
 */

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  try {
    // =====================================================
    // AUTHENTIFICATION
    // =====================================================

    const user = await getUserFromRequest(req);

    if (!user?.id_user) {
      return res.status(401).json({
        success: false,
        message: "Utilisateur non authentifié.",
      });
    }

    const idUser = Number(user.id_user);

    if (!Number.isInteger(idUser) || idUser <= 0) {
      return res.status(401).json({
        success: false,
        message: "Identifiant utilisateur invalide.",
      });
    }

    const url = req.url || "";
    const method = req.method || "GET";

    const parsedUrl = new URL(url, "http://localhost");
    const pathname = parsedUrl.pathname;
    const searchParams = parsedUrl.searchParams;

    // =====================================================
    // GET /api/pistes
    //
    // Récupère toutes les pistes actives de l'utilisateur.
    //
    // Possibilité :
    // /api/pistes?type=metier
    // /api/pistes?type=filiere
    // /api/pistes
    // =====================================================

    if (method === "GET" && pathname.endsWith("/pistes")) {
      const type = searchParams.get("type");

      if (type && !["metier", "filiere"].includes(type)) {
        return res.status(400).json({
          success: false,
          message: "Le type doit être 'metier' ou 'filiere'.",
        });
      }

      let query = supabase
        .from("piste_utilisateur")
        .select(`
          id_piste,
          id_user,
          type_piste,
          id_metier,
          id_filiere,
          date_ajout,
          statut,
          metier (
            id_metier,
            nom,
            description,
            profil_riasec
          ),
          filiere (
            id_filiere,
            nom,
            description,
            domaine,
            duree
          )
        `)
        .eq("id_user", idUser)
        .eq("statut", "active")
        .order("date_ajout", { ascending: false });

      if (type) {
        query = query.eq("type_piste", type);
      }

      const { data, error } = await query;

      if (error) {
        console.error("GET /pistes error:", error);

        return res.status(500).json({
          success: false,
          message: "Impossible de récupérer les pistes.",
          error: error.message,
        });
      }

      return res.status(200).json({
        success: true,
        data: data || [],
        total: data?.length || 0,
      });
    }

    // =====================================================
    // GET /api/pistes/check
    //
    // Vérifie si une piste existe déjà.
    //
    // Exemple :
    // /api/pistes/check?type_piste=metier&id_metier=15
    //
    // ou :
    // /api/pistes/check?type_piste=filiere&id_filiere=12
    // =====================================================

    if (method === "GET" && pathname.includes("/pistes/check")) {
      const typePiste = searchParams.get("type_piste");

      if (!["metier", "filiere"].includes(typePiste)) {
        return res.status(400).json({
          success: false,
          message: "Le type de piste doit être 'metier' ou 'filiere'.",
        });
      }

      let query = supabase
        .from("piste_utilisateur")
        .select(`
          id_piste,
          type_piste,
          id_metier,
          id_filiere,
          statut,
          date_ajout
        `)
        .eq("id_user", idUser)
        .eq("type_piste", typePiste)
        .eq("statut", "active")
        .limit(1);

      if (typePiste === "metier") {
        const idMetier = Number(searchParams.get("id_metier"));

        if (!Number.isInteger(idMetier) || idMetier <= 0) {
          return res.status(400).json({
            success: false,
            message: "id_metier invalide.",
          });
        }

        query = query.eq("id_metier", idMetier);
      }

      if (typePiste === "filiere") {
        const idFiliere = Number(searchParams.get("id_filiere"));

        if (!Number.isInteger(idFiliere) || idFiliere <= 0) {
          return res.status(400).json({
            success: false,
            message: "id_filiere invalide.",
          });
        }

        query = query.eq("id_filiere", idFiliere);
      }

      const { data, error } = await query.maybeSingle();

      if (error) {
        console.error("GET /pistes/check error:", error);

        return res.status(500).json({
          success: false,
          message: "Impossible de vérifier la piste.",
          error: error.message,
        });
      }

      return res.status(200).json({
        success: true,
        existe: !!data,
        data: data || null,
      });
    }

    // =====================================================
    // POST /api/pistes
    //
    // Ajoute une piste.
    //
    // Métier :
    // {
    //   type_piste: "metier",
    //   id_metier: 15
    // }
    //
    // Filière :
    // {
    //   type_piste: "filiere",
    //   id_filiere: 12
    // }
    // =====================================================

    if (method === "POST" && pathname.endsWith("/pistes")) {
      const body = req.body || {};

      const typePiste = body.type_piste;

      if (!["metier", "filiere"].includes(typePiste)) {
        return res.status(400).json({
          success: false,
          message: "type_piste doit être 'metier' ou 'filiere'.",
        });
      }

      // ---------------------------------------------------
      // AJOUT D'UN MÉTIER
      // ---------------------------------------------------

      if (typePiste === "metier") {
        const idMetier = Number(body.id_metier);

        if (!Number.isInteger(idMetier) || idMetier <= 0) {
          return res.status(400).json({
            success: false,
            message: "id_metier invalide.",
          });
        }

        // Vérifier que le métier existe
        const { data: metier, error: metierError } = await supabase
          .from("metier")
          .select("id_metier, nom")
          .eq("id_metier", idMetier)
          .maybeSingle();

        if (metierError) {
          console.error("Vérification métier error:", metierError);

          return res.status(500).json({
            success: false,
            message: "Impossible de vérifier le métier.",
            error: metierError.message,
          });
        }

        if (!metier) {
          return res.status(404).json({
            success: false,
            message: "Métier introuvable.",
          });
        }

        // Vérifier si déjà actif
        const { data: pisteExistante, error: existingError } =
          await supabase
            .from("piste_utilisateur")
            .select("id_piste, statut")
            .eq("id_user", idUser)
            .eq("id_metier", idMetier)
            .maybeSingle();

        if (existingError) {
          console.error("Vérification piste métier error:", existingError);

          return res.status(500).json({
            success: false,
            message: "Impossible de vérifier la piste existante.",
            error: existingError.message,
          });
        }

        if (pisteExistante) {
          // Si elle existe mais est archivée, on la réactive.
          if (pisteExistante.statut === "archive") {
            const { data: pisteReactivee, error: updateError } =
              await supabase
                .from("piste_utilisateur")
                .update({
                  statut: "active",
                  date_ajout: new Date().toISOString(),
                })
                .eq("id_piste", pisteExistante.id_piste)
                .eq("id_user", idUser)
                .select(`
                  id_piste,
                  id_user,
                  type_piste,
                  id_metier,
                  id_filiere,
                  date_ajout,
                  statut
                `)
                .single();

            if (updateError) {
              console.error("Réactivation piste métier error:", updateError);

              return res.status(500).json({
                success: false,
                message: "Impossible de réactiver la piste.",
                error: updateError.message,
              });
            }

            return res.status(200).json({
              success: true,
              message: "Piste métier réactivée.",
              deja_existante: true,
              data: pisteReactivee,
            });
          }

          return res.status(200).json({
            success: true,
            message: "Ce métier est déjà dans tes pistes.",
            deja_existante: true,
            data: pisteExistante,
          });
        }

        // Création
        const { data: nouvellePiste, error: insertError } = await supabase
          .from("piste_utilisateur")
          .insert({
            id_user: idUser,
            type_piste: "metier",
            id_metier: idMetier,
            id_filiere: null,
            statut: "active",
          })
          .select(`
            id_piste,
            id_user,
            type_piste,
            id_metier,
            id_filiere,
            date_ajout,
            statut
          `)
          .single();

        if (insertError) {
          console.error("Création piste métier error:", insertError);

          return res.status(500).json({
            success: false,
            message: "Impossible d'ajouter le métier aux pistes.",
            error: insertError.message,
          });
        }

        return res.status(201).json({
          success: true,
          message: "Métier ajouté à tes pistes.",
          deja_existante: false,
          data: nouvellePiste,
        });
      }

      // ---------------------------------------------------
      // AJOUT D'UNE FILIÈRE
      // ---------------------------------------------------

      if (typePiste === "filiere") {
        const idFiliere = Number(body.id_filiere);

        if (!Number.isInteger(idFiliere) || idFiliere <= 0) {
          return res.status(400).json({
            success: false,
            message: "id_filiere invalide.",
          });
        }

        // Vérifier que la filière existe
        const { data: filiere, error: filiereError } = await supabase
          .from("filiere")
          .select("id_filiere, nom")
          .eq("id_filiere", idFiliere)
          .maybeSingle();

        if (filiereError) {
          console.error("Vérification filière error:", filiereError);

          return res.status(500).json({
            success: false,
            message: "Impossible de vérifier la filière.",
            error: filiereError.message,
          });
        }

        if (!filiere) {
          return res.status(404).json({
            success: false,
            message: "Filière introuvable.",
          });
        }

        // Vérifier si déjà active ou archivée
        const { data: pisteExistante, error: existingError } =
          await supabase
            .from("piste_utilisateur")
            .select("id_piste, statut")
            .eq("id_user", idUser)
            .eq("id_filiere", idFiliere)
            .maybeSingle();

        if (existingError) {
          console.error("Vérification piste filière error:", existingError);

          return res.status(500).json({
            success: false,
            message: "Impossible de vérifier la piste existante.",
            error: existingError.message,
          });
        }

        if (pisteExistante) {
          // Réactivation
          if (pisteExistante.statut === "archive") {
            const { data: pisteReactivee, error: updateError } =
              await supabase
                .from("piste_utilisateur")
                .update({
                  statut: "active",
                  date_ajout: new Date().toISOString(),
                })
                .eq("id_piste", pisteExistante.id_piste)
                .eq("id_user", idUser)
                .select(`
                  id_piste,
                  id_user,
                  type_piste,
                  id_metier,
                  id_filiere,
                  date_ajout,
                  statut
                `)
                .single();

            if (updateError) {
              console.error("Réactivation piste filière error:", updateError);

              return res.status(500).json({
                success: false,
                message: "Impossible de réactiver la piste.",
                error: updateError.message,
              });
            }

            return res.status(200).json({
              success: true,
              message: "Piste filière réactivée.",
              deja_existante: true,
              data: pisteReactivee,
            });
          }

          return res.status(200).json({
            success: true,
            message: "Cette filière est déjà dans tes pistes.",
            deja_existante: true,
            data: pisteExistante,
          });
        }

        // Création
        const { data: nouvellePiste, error: insertError } = await supabase
          .from("piste_utilisateur")
          .insert({
            id_user: idUser,
            type_piste: "filiere",
            id_metier: null,
            id_filiere: idFiliere,
            statut: "active",
          })
          .select(`
            id_piste,
            id_user,
            type_piste,
            id_metier,
            id_filiere,
            date_ajout,
            statut
          `)
          .single();

        if (insertError) {
          console.error("Création piste filière error:", insertError);

          return res.status(500).json({
            success: false,
            message: "Impossible d'ajouter la filière aux pistes.",
            error: insertError.message,
          });
        }

        return res.status(201).json({
          success: true,
          message: "Filière ajoutée à tes pistes.",
          deja_existante: false,
          data: nouvellePiste,
        });
      }
    }

    // =====================================================
    // DELETE /api/pistes/:id
    //
    // On archive plutôt que supprimer physiquement.
    // Cela permet de conserver l'historique.
    // =====================================================

    if (method === "DELETE" && pathname.includes("/pistes/")) {
      const morceaux = pathname.split("/").filter(Boolean);
      const idPiste = Number(morceaux[morceaux.length - 1]);

      if (!Number.isInteger(idPiste) || idPiste <= 0) {
        return res.status(400).json({
          success: false,
          message: "Identifiant de piste invalide.",
        });
      }

      // Vérifier que la piste appartient bien à l'utilisateur
      const { data: piste, error: pisteError } = await supabase
        .from("piste_utilisateur")
        .select(`
          id_piste,
          type_piste,
          id_metier,
          id_filiere,
          statut
        `)
        .eq("id_piste", idPiste)
        .eq("id_user", idUser)
        .maybeSingle();

      if (pisteError) {
        console.error("Recherche piste suppression error:", pisteError);

        return res.status(500).json({
          success: false,
          message: "Impossible de vérifier la piste.",
          error: pisteError.message,
        });
      }

      if (!piste) {
        return res.status(404).json({
          success: false,
          message: "Piste introuvable.",
        });
      }

      if (piste.statut === "archive") {
        return res.status(200).json({
          success: true,
          message: "Cette piste est déjà retirée.",
          data: piste,
        });
      }

      const { data: pisteArchivee, error: updateError } = await supabase
        .from("piste_utilisateur")
        .update({
          statut: "archive",
        })
        .eq("id_piste", idPiste)
        .eq("id_user", idUser)
        .select(`
          id_piste,
          id_user,
          type_piste,
          id_metier,
          id_filiere,
          date_ajout,
          statut
        `)
        .single();

      if (updateError) {
        console.error("Archivage piste error:", updateError);

        return res.status(500).json({
          success: false,
          message: "Impossible de retirer la piste.",
          error: updateError.message,
        });
      }

      return res.status(200).json({
        success: true,
        message: "Piste retirée.",
        data: pisteArchivee,
      });
    }

    // =====================================================
    // ROUTE INCONNUE
    // =====================================================

    return res.status(404).json({
      success: false,
      message: "Route pistes inconnue.",
    });

  } catch (error) {
    console.error("Pistes API error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Erreur serveur.",
    });
  }
}