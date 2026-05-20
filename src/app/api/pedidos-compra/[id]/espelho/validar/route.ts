import { NextRequest, NextResponse } from 'next/server'
import { createServerSupabaseClient } from '@/lib/supabase'
import { getCurrentUser } from '@/lib/auth'
import { requirePermission } from '@/lib/permissions'
import { validarEspelho } from '@/lib/espelho-validacao'

export const maxDuration = 60

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    // Auth
    const user = await getCurrentUser()
    if (!user || !user.empresaId) {
      return NextResponse.json({ error: 'Nao autenticado' }, { status: 401 })
    }

    const permCheck = await requirePermission(user, 'pedidos')
    if (!permCheck.allowed) return permCheck.response

    const { id: pedidoId } = await params
    const supabase = createServerSupabaseClient()

    // Validate pedido belongs to this empresa
    const { data: pedido, error: pedidoError } = await supabase
      .from('pedidos_compra')
      .select('id')
      .eq('id', pedidoId)
      .eq('empresa_id', user.empresaId)
      .eq('is_excluded', false)
      .single()

    if (pedidoError || !pedido) {
      return NextResponse.json({ error: 'Pedido nao encontrado' }, { status: 404 })
    }

    // Delegate to shared lib
    const result = await validarEspelho(pedido.id)

    if (!result.success) {
      return NextResponse.json(
        { error: result.error, detalhes: result.detalhes },
        { status: result.status || 500 }
      )
    }

    return NextResponse.json(result)
  } catch (error) {
    console.error('Erro ao validar espelho:', error)
    return NextResponse.json({ error: 'Erro interno ao validar espelho' }, { status: 500 })
  }
}
